"""Dagster assets for the ML training pipeline.

Trains a MLPRegressor user-tower that maps 128-dimensional profile feature
vectors (matching picky-api's profile_features module) to 100-dimensional
embeddings, and exports the model in ONNX format for cross-language inference.
"""

import os
import tempfile

import numpy as np
import pandas as pd
import psycopg2
from botocore.exceptions import ClientError
from dagster import (
    AssetExecutionContext,
    MaterializeResult,
    MetadataValue,
    asset,
)
from dagster_aws.s3 import S3Resource
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType
from sklearn.neural_network import MLPRegressor

__all__ = ["customer_vectors", "training_data", "trained_model"]

S3_BUCKET = os.environ.get("S3_BUCKET", "picky-models")
S3_MODEL_KEY = os.environ.get("S3_MODEL_KEY", "models/picky-recs/model.onnx")

_DEFAULT_TRAINING_DB_URL = "postgresql://picky:Password123@postgres.picky.local:5432/training"

# Must match picky-api/src/profile_features.rs (OUT_DIMS = 128)
# and picky-api/src/model.rs (embed_user output = 100).
USER_VECTOR_DIM = 128
EMBEDDING_DIM = 100


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
    description="Static training data for a simple food preference classifier. "
    "Features: spicy (0/1), sweet (0/1), salty (0/1), warm (0/1). "
    "Label: 1 = user likes it, 0 = user dislikes it.",
    deps=["recipe_vectors", "customer_vectors"],
)
def training_data(context: AssetExecutionContext) -> pd.DataFrame:
    """Return a hardcoded dataset of food preferences."""
    data = {
        "spicy": [1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0],
        "sweet": [0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1],
        "salty": [1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0],
        "warm": [1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0],
        "liked": [1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1],
    }

    df = pd.DataFrame(data)

    context.log.info(f"Loaded static training data with shape: {df.shape}")
    context.log.info(f"Liked distribution:\n{df['liked'].value_counts().to_string()}")

    return df


@asset(
    description="Train a MLPRegressor user-tower that maps 128-dimensional "
    "profile feature vectors (as produced by picky-api's profile_features module) "
    "to 100-dimensional embeddings, then export the model in ONNX format to S3 "
    "(MinIO). Using a regressor avoids the ONNX ZipMap output type that classifiers "
    "emit, which is not yet supported by ort 2.x.",
)
def trained_model(
    context: AssetExecutionContext,
    s3: S3Resource,
) -> MaterializeResult:
    """Train a user-tower MLP, convert to ONNX, and upload to S3."""
    rng = np.random.RandomState(42)

    # Generate synthetic 128-dim unit-normalised user vectors.
    # These mirror the vectors produced by profile_features::featurize in picky-api.
    n_samples = 2000
    X = rng.randn(n_samples, USER_VECTOR_DIM).astype(np.float32)
    norms = np.linalg.norm(X, axis=1, keepdims=True)
    X = X / np.maximum(norms, 1e-10)

    # Synthetic targets: 100-dim embeddings derived from a low-rank latent structure
    # so the MLP has a non-trivial projection to learn.
    latent = rng.randn(n_samples, 16).astype(np.float32)
    w_out = rng.randn(16, EMBEDDING_DIM).astype(np.float32)
    y = latent @ w_out
    y_norms = np.linalg.norm(y, axis=1, keepdims=True)
    y = y / np.maximum(y_norms, 1e-10)

    model = MLPRegressor(
        hidden_layer_sizes=(64,),
        activation="relu",
        max_iter=300,
        random_state=42,
    )
    model.fit(X, y)

    train_r2 = model.score(X, y)
    context.log.info(f"Training R² score: {train_r2:.4f}")

    # Convert to ONNX — MLPRegressor outputs a plain float32 tensor of shape
    # (N, EMBEDDING_DIM); no ZipMap is emitted, so ort can load this without
    # hitting the unimplemented Map type branch.
    initial_types = [("features", FloatTensorType([None, USER_VECTOR_DIM]))]
    onnx_model = convert_sklearn(model, "user_tower", initial_types)
    # convert_sklearn returns ModelProto | None in stubs, but never returns None on success.
    model_bytes: bytes = onnx_model.SerializeToString()  # type: ignore[union-attr]
    context.log.info(f"ONNX model size: {len(model_bytes)} bytes")

    # Ensure the bucket exists
    s3_client = s3.get_client()
    try:
        s3_client.head_bucket(Bucket=S3_BUCKET)
        context.log.info(f"Bucket '{S3_BUCKET}' already exists.")
    except ClientError:
        s3_client.create_bucket(Bucket=S3_BUCKET)
        context.log.info(f"Created bucket '{S3_BUCKET}'.")

    # Upload the ONNX model
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
            "r2_score": MetadataValue.float(train_r2),
            "s3_path": MetadataValue.text(s3_path),
            "format": MetadataValue.text("ONNX"),
            "model_size_bytes": MetadataValue.int(len(model_bytes)),
            "input_dim": MetadataValue.int(USER_VECTOR_DIM),
            "output_dim": MetadataValue.int(EMBEDDING_DIM),
            "samples": MetadataValue.int(n_samples),
            "hidden_layers": MetadataValue.text("(64,)"),
        },
    )

