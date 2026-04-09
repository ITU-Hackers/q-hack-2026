"""Dagster assets for the ML training pipeline.

Trains a two-tower model (UserTower → 100-dim meal embedding space) using
TensorFlow Recommenders' in-batch softmax retrieval loss, and exports the user
tower in ONNX format for cross-language inference in picky-api.
"""

import os
import tempfile
from pathlib import Path

# Must be set before TensorFlow is imported.
os.environ.setdefault("TF_USE_LEGACY_KERAS", "1")

import numpy as np
import pandas as pd
import psycopg2
import tensorflow as tf
import tensorflow_recommenders as tfrs
import tf2onnx
from botocore.exceptions import ClientError
from dagster import (
    AssetExecutionContext,
    MaterializeResult,
    MetadataValue,
    asset,
)
from dagster_aws.s3 import S3Resource
from qdrant_client import QdrantClient

__all__ = ["customer_vectors", "trained_model"]

S3_BUCKET = os.environ.get("S3_BUCKET", "picky-models")
S3_MODEL_KEY = os.environ.get("S3_MODEL_KEY", "models/picky-recs/model.onnx")

_DEFAULT_TRAINING_DB_URL = (
    "postgresql://picky:Password123@postgres.picky.local:5432/training"
)

# Must match picky-api/src/profile_features.rs (OUT_DIMS = 128)
# and picky-api/src/model.rs (embed_user output = 100).
USER_VECTOR_DIM = 128
EMBEDDING_DIM = 100

# Must match profile_features.rs constants exactly.
_RAW_DIMS = 29
_HEALTH_GOALS = ["balanced", "mediterranean", "high-protein"]
_COOKING_TIMES = ["quick", "moderate", "enthusiast"]
_BUDGETS = ["budget", "moderate", "flexible"]
_CUISINES = [
    "Asian",
    "Italian",
    "French",
    "Mexican",
    "Indian",
    "Mediterranean",
    "American",
]
_RESTRICTIONS = [
    "nut-allergy",
    "gluten-free",
    "vegan",
    "vegetarian",
    "dairy-free",
    "halal",
]

_ASSETS_DIR = Path(__file__).parent
_SERVICE_DIR = _ASSETS_DIR.parents[1]
_FOOD2VEC_PATH = str(_SERVICE_DIR / "picky_recs" / "data" / "food2vec.txt")

# Ingredients in the food2vec vocabulary that map to each preference/cuisine/goal.
# Keys must match food2vec.txt exactly (lowercase, single-word or underscore-joined).
_PREF_INGREDIENTS: dict[str, list[str]] = {
    "fish": ["salmon", "tuna", "cod", "shrimp"],
    "pork": ["pork", "bacon", "ham", "sausage"],
    "beef": ["beef", "lamb", "turkey"],
    "dairy": ["cheese", "milk", "butter", "yogurt"],
    "spicy": ["chili", "jalapeno", "ginger", "cumin", "coriander"],
}
_HEALTH_GOAL_INGREDIENTS: dict[str, list[str]] = {
    "balanced": ["chicken", "tomato", "rice", "spinach", "eggs"],
    "mediterranean": ["olive", "feta", "tomato", "lemon", "eggplant"],
    "high-protein": ["chicken", "eggs", "turkey", "tuna", "beef"],
}
_CUISINE_INGREDIENTS: dict[str, list[str]] = {
    "Asian": ["rice", "ginger", "soy", "noodles", "miso"],
    "Italian": ["pasta", "tomato", "cheese", "olive"],
    "French": ["butter", "mushroom", "lemon"],
    "Mexican": ["chili", "jalapeno", "tomato"],
    "Indian": ["cumin", "coriander", "curry", "chickpeas", "lentils"],
    "Mediterranean": ["olive", "feta", "tomato", "eggplant"],
    "American": ["beef", "bacon", "cheese"],
}
_RESTRICTION_INGREDIENTS: dict[str, list[str]] = {
    "vegan": ["tofu", "lentils", "chickpeas", "spinach", "kale"],
    "vegetarian": ["tofu", "eggs", "cheese", "mushrooms", "lentils"],
    "gluten-free": ["rice", "spinach", "tomato", "eggs"],
    "dairy-free": ["lemon", "olive", "spinach", "tomato"],
}

VECTOR_FEATURE_NAMES = [
    "spend_trend",
    "budget_util_rate",
    "loyalty_staples_fraction",
    "loyalty_one_time_fraction",
    "avg_reorder_interval_days",
    "top_category_concentration",
    "order_interval_consistency",
    "protein_fraction",
    "dairy_fraction",
    "carbs_fraction",
    "vegetables_fraction",
    "snacks_fraction",
]


def _proj(i: int, j: int) -> float:
    """Deterministic projection value for matrix element M[i][j].

    Python port of profile_features::proj in picky-api/src/profile_features.rs.
    Uses the same three-round 64-bit finalisation mix so every (i, j) pair maps
    to a stable value in [-1.0, 1.0] without storing the full matrix.
    All arithmetic wraps at 2^64 to match Rust's u64 semantics.
    """
    M = 1 << 64
    x = (i * 6_364_136_223_846_793_005 + j) % M
    x = (x * 2_862_933_555_777_941_757 + 3_037_000_493) % M
    x ^= x >> 33
    x = (x * 0xFF51AFD7ED558CCD) % M
    x ^= x >> 33
    x = (x * 0xC4CEB9FE1A85EC53) % M
    x ^= x >> 33
    return float(x) / 18_446_744_073_709_551_615.0 * 2.0 - 1.0


# Precompute the projection matrix once; shape (RAW_DIMS=29, OUT_DIMS=128).
_PROJ_MATRIX: np.ndarray = np.array(
    [[_proj(i, j) for j in range(USER_VECTOR_DIM)] for i in range(_RAW_DIMS)],
    dtype=np.float32,
)


def _featurize_profile(
    pref_fish: float,
    pref_pork: float,
    pref_beef: float,
    pref_dairy: float,
    pref_spicy: float,
    adults: int,
    kids: int,
    health_goal: str,
    cooking_time: str,
    budget: str,
    cuisines: list[str],
    restrictions: list[str],
) -> np.ndarray:
    """Python port of profile_features::featurize.

    Returns a 128-dimensional unit-norm float32 vector that exactly mirrors the
    vector picky-api produces for the same profile at inference time.
    """
    raw = np.zeros(_RAW_DIMS, dtype=np.float32)
    c = 0

    # Ingredient preferences normalised to [0, 1]  (5 dims)
    raw[c] = min(pref_fish, 1.0)
    c += 1
    raw[c] = min(pref_pork, 1.0)
    c += 1
    raw[c] = min(pref_beef, 1.0)
    c += 1
    raw[c] = min(pref_dairy, 1.0)
    c += 1
    raw[c] = min(pref_spicy, 1.0)
    c += 1

    # Household size  (2 dims)
    raw[c] = min(adults / 6.0, 1.0)
    c += 1
    raw[c] = min(kids / 4.0, 1.0)
    c += 1

    # Health goal one-hot  (3 dims)
    for goal in _HEALTH_GOALS:
        raw[c] = 1.0 if health_goal == goal else 0.0
        c += 1

    # Cooking time one-hot  (3 dims)
    for ct in _COOKING_TIMES:
        raw[c] = 1.0 if cooking_time == ct else 0.0
        c += 1

    # Budget one-hot  (3 dims)
    for b in _BUDGETS:
        raw[c] = 1.0 if budget == b else 0.0
        c += 1

    # Cuisine multi-hot  (7 dims)
    for cu in _CUISINES:
        raw[c] = 1.0 if cu in cuisines else 0.0
        c += 1

    # Dietary restrictions multi-hot  (6 dims)
    for r in _RESTRICTIONS:
        raw[c] = 1.0 if r in restrictions else 0.0
        c += 1

    assert c == _RAW_DIMS, f"raw feature dimension mismatch: {c} != {_RAW_DIMS}"

    # Random projection: RAW_DIMS (29) → OUT_DIMS (128)
    projected = raw @ _PROJ_MATRIX  # shape (128,)

    # L2 normalisation
    norm = np.linalg.norm(projected)
    if norm > 1e-10:
        projected /= norm

    return projected.astype(np.float32)


def _load_food2vec(path: str) -> dict[str, np.ndarray]:
    """Parse food2vec.txt into a dict mapping ingredient name → float32 (100,) array."""
    emb: dict[str, np.ndarray] = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) != EMBEDDING_DIM + 1:
                continue
            emb[parts[0]] = np.array(parts[1:], dtype=np.float32)
    return emb


def _profile_target(
    embeddings: dict[str, np.ndarray],
    pref_fish: float,
    pref_pork: float,
    pref_beef: float,
    pref_dairy: float,
    pref_spicy: float,
    health_goal: str,
    cuisines: list[str],
    restrictions: list[str],
) -> np.ndarray:
    """Build a 100-dim target embedding by mean-pooling food2vec vectors.

    Ingredients are selected and weighted based on the user's preferences so
    the target lies in the part of the food2vec space that best matches what
    this user would enjoy.
    """
    accum = np.zeros(EMBEDDING_DIM, dtype=np.float32)
    total_weight = 0.0

    def _add(ingredient: str, weight: float) -> None:
        nonlocal total_weight
        if ingredient in embeddings:
            accum[:] += embeddings[ingredient] * weight
            total_weight += weight

    # Always include neutral base ingredients with low weight
    for ing in ["garlic", "tomato", "lemon"]:
        _add(ing, 0.3)

    # Ingredient preference dimensions — weight proportional to preference value
    for key, pref in [
        ("fish", pref_fish),
        ("pork", pref_pork),
        ("beef", pref_beef),
        ("dairy", pref_dairy),
        ("spicy", pref_spicy),
    ]:
        if pref > 0.3:
            for ing in _PREF_INGREDIENTS[key]:
                _add(ing, pref)

    # Health goal
    for ing in _HEALTH_GOAL_INGREDIENTS.get(health_goal, []):
        _add(ing, 0.8)

    # Cuisines
    for cuisine in cuisines:
        for ing in _CUISINE_INGREDIENTS.get(cuisine, []):
            _add(ing, 0.6)

    # Dietary restrictions
    for restr in restrictions:
        for ing in _RESTRICTION_INGREDIENTS.get(restr, []):
            _add(ing, 0.7)

    if total_weight > 0:
        accum /= total_weight

    # L2-normalise so targets are on the unit sphere (matching Qdrant cosine distance)
    norm = np.linalg.norm(accum)
    if norm > 1e-10:
        accum /= norm

    return accum


class UserTower(tf.keras.Model):
    """Projects a 128-dim user profile vector into the 100-dim meal embedding space."""

    def __init__(self) -> None:
        super().__init__()
        self.dense = tf.keras.Sequential(
            [
                tf.keras.layers.Dense(256, activation="relu"),
                tf.keras.layers.Dense(128, activation="relu"),
                tf.keras.layers.Dense(EMBEDDING_DIM),
            ]
        )

    def call(self, user_vector: tf.Tensor) -> tf.Tensor:  # type: ignore[override]
        return self.dense(user_vector)


class MealTower(tf.keras.Model):
    """Passthrough — meal embeddings from food2vec/Qdrant are used as-is."""

    def call(self, meal_embedding: tf.Tensor) -> tf.Tensor:  # type: ignore[override]
        return meal_embedding


class MealRecommender(tfrs.Model):
    """Two-tower retrieval model trained with TFRS in-batch softmax loss.

    compute_loss pairs each (user_vector, meal_embedding) in the batch as a
    positive example and treats all other meal embeddings in the same batch as
    negatives — this is the standard in-batch sampled-softmax retrieval loss
    from the TFRS Retrieval task.
   """

    def __init__(self, meals_dataset: tf.data.Dataset) -> None:
        super().__init__()
        self.user_tower = UserTower()
        self.meal_tower = MealTower()
        self.task: tfrs.tasks.Retrieval = tfrs.tasks.Retrieval(
            metrics=tfrs.metrics.FactorizedTopK(
                candidates=meals_dataset.batch(128).map(self.meal_tower),
            ),
        )

    def compute_loss(
        self,
        inputs: dict[str, tf.Tensor],
        training: bool = False,
    ) -> tf.Tensor:
        user_embeddings = self.user_tower(inputs["user_vector"])
        meal_embeddings = self.meal_tower(inputs["meal_embedding"])
        return self.task(user_embeddings, meal_embeddings)  # type: ignore[call-arg]


def _fetch_meal_embeddings(url: str, collection: str) -> tuple[list[str], np.ndarray]:
    """Scroll all vectors from a Qdrant collection and return (ids, matrix)."""
    client = QdrantClient(url=url)
    ids: list[str] = []
    vectors: list[list[float]] = []
    offset = None
    while True:
        result, offset = client.scroll(
            collection_name=collection,
            with_vectors=True,
            limit=100,
            offset=offset,
        )
        for point in result:
            ids.append(str(point.id))
            vectors.append(point.vector)  # type: ignore[arg-type]
        if offset is None:
            break
    return ids, np.array(vectors, dtype=np.float32)


@asset(
    description=(
        "Read weekly ML metrics from PostgreSQL and aggregate them into "
        "per-customer feature vectors, averaged over all recorded weeks. "
        "Depends on seed_synthetic_users having populated the weekly_metrics table."
    ),
    deps=["seed_synthetic_users"],
)
def customer_vectors(context: AssetExecutionContext) -> pd.DataFrame:
    """Query weekly_metrics and return a DataFrame with one row per customer."""
    db_url = os.environ.get("TRAINING_DB_URL", _DEFAULT_TRAINING_DB_URL)
    conn = psycopg2.connect(db_url)

    cols = ", ".join(f"AVG({f}) AS {f}" for f in VECTOR_FEATURE_NAMES)
    query = f"""
        SELECT user_id, {cols}
        FROM user_weekly_metrics
        GROUP BY user_id
        ORDER BY user_id
    """  # noqa: S608 — internal training DB, no user-supplied input

    df = pd.read_sql(query, conn)
    conn.close()

    context.log.info(
        f"Built customer vectors: {len(df)} users × {len(df.columns) - 1} features"
    )
    context.log.info(f"Feature columns: {VECTOR_FEATURE_NAMES}")

    return df


@asset(
    description=(
        "Train a two-tower MealRecommender using TensorFlow Recommenders' "
        "in-batch softmax retrieval loss. The UserTower maps 128-dim profile "
        "feature vectors (matching picky-api's profile_features module) into "
        "the 100-dim food2vec meal embedding space. Positive (user, meal) pairs "
        "are constructed synthetically: user vectors are featurized via the same "
        "deterministic random-projection as profile_features.rs, and each user's "
        "paired meal embedding is built by mean-pooling food2vec ingredient vectors "
        "weighted by their stated preferences. The meal corpus fetched from Qdrant "
        "is used for FactorizedTopK evaluation metrics. The trained UserTower is "
        "exported in ONNX format and uploaded to S3 (MinIO)."
    ),
    deps=["recipe_vectors"],
)
def trained_model(
    context: AssetExecutionContext,
    s3: S3Resource,
) -> MaterializeResult:
    """Train the two-tower model with TFRS retrieval loss, export to ONNX, upload to S3."""
    rng = np.random.RandomState(42)

    embeddings = _load_food2vec(_FOOD2VEC_PATH)
    context.log.info(
        f"Loaded {len(embeddings)} food2vec embeddings from {_FOOD2VEC_PATH}"
    )

    n_samples = 3000
    X_rows: list[np.ndarray] = []
    y_rows: list[np.ndarray] = []

    for _ in range(n_samples):
        pref_fish = float(rng.uniform(0.0, 1.0))
        pref_pork = float(rng.uniform(0.0, 1.0))
        pref_beef = float(rng.uniform(0.0, 1.0))
        pref_dairy = float(rng.uniform(0.0, 1.0))
        pref_spicy = float(rng.uniform(0.0, 1.0))
        adults = int(rng.randint(1, 7))
        kids = int(rng.randint(0, 5))
        health_goal = str(rng.choice(_HEALTH_GOALS))
        cooking_time = str(rng.choice(_COOKING_TIMES))
        budget = str(rng.choice(_BUDGETS))

        n_cuisines = int(rng.randint(1, 4))
        cuisines = list(rng.choice(_CUISINES, size=n_cuisines, replace=False))

        n_restrictions = int(rng.randint(0, 3))
        restrictions: list[str] = (
            list(rng.choice(_RESTRICTIONS, size=n_restrictions, replace=False))
            if n_restrictions > 0
            else []
        )

        x = _featurize_profile(
            pref_fish,
            pref_pork,
            pref_beef,
            pref_dairy,
            pref_spicy,
            adults,
            kids,
            health_goal,
            cooking_time,
            budget,
            cuisines,
            restrictions,
        )
        y = _profile_target(
            embeddings,
            pref_fish,
            pref_pork,
            pref_beef,
            pref_dairy,
            pref_spicy,
            health_goal,
            cuisines,
            restrictions,
        )
        X_rows.append(x)
        y_rows.append(y)

    X = np.array(X_rows, dtype=np.float32)  # (n_samples, 128)
    y = np.array(y_rows, dtype=np.float32)  # (n_samples, 100)

    context.log.info(
        f"Generated {n_samples} training pairs; X shape {X.shape}, y shape {y.shape}"
    )

    # ── Fetch meal corpus from Qdrant for FactorizedTopK metrics ─────────────
    qdrant_url = os.environ.get("QDRANT_URL", "http://localhost:6333")
    qdrant_collection = os.environ.get("QDRANT_RECIPES_COLLECTION", "recipes")
    meal_ids: list[str] = []
    meal_vecs: np.ndarray

    try:
        meal_ids, meal_vecs = _fetch_meal_embeddings(qdrant_url, qdrant_collection)
        context.log.info(
            f"Fetched {len(meal_ids)} meal embeddings from Qdrant "
            f"collection '{qdrant_collection}' for top-K metrics."
        )
    except Exception as exc:  # noqa: BLE001
        context.log.warning(
            f"Could not fetch meal embeddings from Qdrant ({exc}). "
            "Falling back to food2vec targets as the metrics corpus."
        )
        meal_vecs = y

    meals_ds = tf.data.Dataset.from_tensor_slices(meal_vecs.astype(np.float32))

    interactions_ds = tf.data.Dataset.from_tensor_slices(
        {
            "user_vector": tf.constant(X),
            "meal_embedding": tf.constant(y),
        }  # type: ignore[arg-type]
    ).shuffle(n_samples, seed=42)

    rec_model = MealRecommender(meals_dataset=meals_ds)
    rec_model.compile(optimizer=tf.keras.optimizers.Adagrad(learning_rate=0.1))

    history = rec_model.fit(interactions_ds.batch(256), epochs=10, verbose=0)

    final_loss = float(history.history["loss"][-1])
    context.log.info(f"Training complete. Final retrieval loss: {final_loss:.6f}")

    # Log top-K metrics if they were computed
    for metric_name, values in history.history.items():
        if metric_name != "loss":
            context.log.info(f"  {metric_name}: {float(values[-1]):.4f}")

    # ── Export UserTower to ONNX via tf2onnx ──────────────────────────────────
    input_signature = (
        tf.TensorSpec([None, USER_VECTOR_DIM], tf.float32, name="features"),
    )
    onnx_proto, _ = tf2onnx.convert.from_keras(
        rec_model.user_tower,
        input_signature=input_signature,
        opset=13,
    )
    model_bytes: bytes = onnx_proto.SerializeToString()
    context.log.info(f"ONNX model size: {len(model_bytes)} bytes")

    # ── Ensure bucket exists and upload ───────────────────────────────────────
    s3_client = s3.get_client()
    try:
        s3_client.head_bucket(Bucket=S3_BUCKET)
        context.log.info(f"Bucket '{S3_BUCKET}' already exists.")
    except ClientError:
        s3_client.create_bucket(Bucket=S3_BUCKET)
        context.log.info(f"Created bucket '{S3_BUCKET}'.")

    with tempfile.NamedTemporaryFile(suffix=".onnx") as tmp:
        tmp.write(model_bytes)
        tmp.flush()
        s3_client.upload_file(
            Filename=tmp.name,
            Bucket=S3_BUCKET,
            Key=S3_MODEL_KEY,
        )

    s3_path = f"s3://{S3_BUCKET}/{S3_MODEL_KEY}"
    context.log.info(f"Model uploaded to {s3_path}")

    return MaterializeResult(
        metadata={
            "final_loss": MetadataValue.float(final_loss),
            "s3_path": MetadataValue.text(s3_path),
            "format": MetadataValue.text("ONNX"),
            "model_size_bytes": MetadataValue.int(len(model_bytes)),
            "input_dim": MetadataValue.int(USER_VECTOR_DIM),
            "output_dim": MetadataValue.int(EMBEDDING_DIM),
            "samples": MetadataValue.int(n_samples),
            "hidden_layers": MetadataValue.text("(256, 128)"),
            "food2vec_vocab": MetadataValue.int(len(embeddings)),
            "meal_corpus_size": MetadataValue.int(len(meal_ids) or len(meal_vecs)),
            "loss_fn": MetadataValue.text("TFRS in-batch softmax retrieval"),
        },
    )
