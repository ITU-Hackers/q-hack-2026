"""Dagster assets for embedding recipes into Qdrant via food2vec.

Each recipe is vectorized by mean-pooling the food2vec embeddings of its
ingredients (100-dimensional float32 vectors), then upserted into a dedicated
Qdrant collection for semantic recipe search.
"""

import os
import uuid
from pathlib import Path

import numpy as np
import psycopg2
from dagster import AssetExecutionContext, MaterializeResult, MetadataValue, asset
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, PointStruct, VectorParams

__all__ = ["recipe_collection", "recipe_vectors"]

FOOD2VEC_DIM = 100
BATCH_SIZE = 50

_ASSETS_DIR = Path(__file__).parent
_SERVICE_DIR = _ASSETS_DIR.parents[1]
FOOD2VEC_PATH = str(_SERVICE_DIR / "picky_recs" / "data" / "food2vec.txt")

QDRANT_URL = os.environ["QDRANT_URL"]
QDRANT_COLLECTION = os.environ["QDRANT_RECIPES_COLLECTION"]
PRIMARY_POSTGRES_URL = os.environ["PRIMARY_POSTGRES_URL"]

_UNITS: frozenset[str] = frozenset(
    {
        "tsp",
        "tsps",
        "teaspoon",
        "teaspoons",
        "tbsp",
        "tbsps",
        "tablespoon",
        "tablespoons",
        "cup",
        "cups",
        "oz",
        "ounce",
        "ounces",
        "lb",
        "lbs",
        "pound",
        "pounds",
        "g",
        "gram",
        "grams",
        "kg",
        "kilogram",
        "kilograms",
        "ml",
        "milliliter",
        "milliliters",
        "l",
        "liter",
        "liters",
        "pint",
        "pints",
        "quart",
        "quarts",
        "gallon",
        "gallons",
        "can",
        "cans",
        "package",
        "packages",
        "pkg",
        "bunch",
        "bunches",
        "clove",
        "cloves",
        "slice",
        "slices",
        "piece",
        "pieces",
        "handful",
        "pinch",
        "dash",
    }
)


def _normalize(ingredient: str) -> str:
    """Mirror the Rust normalize() logic: strip quantities/units, lowercase, underscore-join."""
    tokens = []
    for tok in ingredient.split():
        try:
            float(tok)
            continue
        except ValueError:
            pass
        if "/" in tok:
            parts = tok.split("/", 1)
            try:
                int(parts[0])
                int(parts[1])
                continue
            except ValueError:
                pass
        if tok.lower() in _UNITS:
            continue
        tokens.append(tok.lower())
    return "_".join(tokens)


def load_food2vec(path: str) -> dict[str, np.ndarray]:
    """Parse food2vec.txt into a dict mapping ingredient name → float32 array of shape (100,)."""
    embeddings: dict[str, np.ndarray] = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) != FOOD2VEC_DIM + 1:
                continue
            name = parts[0]
            embeddings[name] = np.array(parts[1:], dtype=np.float32)
    return embeddings


def vectorize(
    embeddings: dict[str, np.ndarray],
    ingredients: list[str],
) -> tuple[np.ndarray, int, int]:
    """Mean-pool food2vec embeddings for a list of ingredient strings."""
    total = len(ingredients)
    accum = np.zeros(FOOD2VEC_DIM, dtype=np.float32)
    matched = 0
    for raw in ingredients:
        key = _normalize(raw)
        if key in embeddings:
            accum += embeddings[key]
            matched += 1
    if matched > 0:
        accum /= matched
    return accum, matched, total


def _dish_uuid(dish: str) -> str:
    """Deterministic UUID from dish name — stable across pipeline reruns."""
    return str(uuid.uuid5(uuid.NAMESPACE_DNS, f"picky-recipe:{dish}"))


@asset(
    description=(
        "Ensure the Qdrant 'recipes' collection exists with 100-dim cosine vectors."
    ),
)
def recipe_collection(context: AssetExecutionContext) -> None:
    client = QdrantClient(url=QDRANT_URL)
    existing = {c.name for c in client.get_collections().collections}
    if QDRANT_COLLECTION not in existing:
        client.create_collection(
            collection_name=QDRANT_COLLECTION,
            vectors_config=VectorParams(size=FOOD2VEC_DIM, distance=Distance.COSINE),
        )
        context.log.info(f"Created Qdrant collection '{QDRANT_COLLECTION}'")
    else:
        context.log.info(f"Qdrant collection '{QDRANT_COLLECTION}' already exists")


@asset(
    deps=["recipe_collection"],
    description=(
        "Embed all recipes from PostgreSQL into Qdrant using food2vec "
        "ingredient vectors (100-dim float32, mean-pooled). Upserted in "
        "batches of 50. Re-materializing picks up any new or updated dishes."
    ),
)
def recipe_vectors(context: AssetExecutionContext) -> MaterializeResult:
    embeddings = load_food2vec(FOOD2VEC_PATH)
    context.log.info(
        f"Loaded {len(embeddings)} food2vec embeddings from {FOOD2VEC_PATH}"
    )

    conn = psycopg2.connect(PRIMARY_POSTGRES_URL)
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT r.dish, r.region, array_agg(i.name) AS ingredients
                FROM recipes r
                JOIN recipe_ingredients ri ON ri.recipe_id = r.id
                JOIN ingredients i ON i.id = ri.ingredient_id
                GROUP BY r.id, r.dish, r.region
                ORDER BY r.dish
            """)
            rows = cur.fetchall()
    finally:
        conn.close()

    context.log.info(f"Loaded {len(rows)} recipes from PostgreSQL")

    client = QdrantClient(url=QDRANT_URL)

    points: list[PointStruct] = []
    total_matched = 0
    zero_match_count = 0

    for dish, region, ingredients in rows:
        ingredients = ingredients or []

        vec, matched, total = vectorize(embeddings, ingredients)
        total_matched += matched

        if matched == 0:
            zero_match_count += 1
            context.log.warning(f"No embeddings matched for '{dish}': {ingredients}")

        points.append(
            PointStruct(
                id=_dish_uuid(dish),
                vector=vec.tolist(),
                payload={
                    "region": region,
                    "dish": dish,
                    "ingredients": ingredients,
                    "matched": matched,
                    "total": total,
                },
            )
        )

        if len(points) >= BATCH_SIZE:
            client.upsert(collection_name=QDRANT_COLLECTION, points=points)
            context.log.info(f"Upserted batch of {len(points)} points")
            points = []

    if points:
        client.upsert(collection_name=QDRANT_COLLECTION, points=points)
        context.log.info(f"Upserted final batch of {len(points)} points")

    avg_match_rate = total_matched / max(sum(len(r[2] or []) for r in rows), 1)

    return MaterializeResult(
        metadata={
            "recipes_embedded": MetadataValue.int(len(rows)),
            "zero_match_recipes": MetadataValue.int(zero_match_count),
            "avg_ingredient_match_rate": MetadataValue.float(avg_match_rate),
            "collection": MetadataValue.text(QDRANT_COLLECTION),
            "vector_dim": MetadataValue.int(FOOD2VEC_DIM),
        },
    )
