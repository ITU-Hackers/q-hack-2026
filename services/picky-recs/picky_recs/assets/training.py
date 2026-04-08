"""Dagster assets for the ML training pipeline.

Uses static hardcoded data to train a simple DecisionTreeClassifier
and exports the model in ONNX format for cross-language inference.
"""

import os
import tempfile

import numpy as np
import pandas as pd
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
from sklearn.tree import DecisionTreeClassifier

__all__ = ["training_data", "trained_model"]

S3_BUCKET = os.environ.get("S3_BUCKET", "picky-models")
S3_MODEL_KEY = os.environ.get("S3_MODEL_KEY", "models/picky-recs/model.onnx")

FEATURE_NAMES = ["spicy", "sweet", "salty", "warm"]


@asset(
    description="Static training data for a simple food preference classifier. "
    "Features: spicy (0/1), sweet (0/1), salty (0/1), warm (0/1). "
    "Label: 1 = user likes it, 0 = user dislikes it.",
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
    description="Train a DecisionTreeClassifier on the static food preference "
    "data and export the model in ONNX format to S3 (MinIO).",
)
def trained_model(
    context: AssetExecutionContext,
    s3: S3Resource,
    training_data: pd.DataFrame,
) -> MaterializeResult:
    """Train a decision tree, convert to ONNX, and upload to S3."""
    X = training_data[FEATURE_NAMES].to_numpy(dtype=np.float32)
    y = training_data["liked"].to_numpy()

    model = DecisionTreeClassifier(max_depth=3, random_state=42)
    model.fit(X, y)

    accuracy = model.score(X, y)
    context.log.info(f"Training accuracy: {accuracy:.4f}")

    # Convert to ONNX format
    initial_types = [("features", FloatTensorType([None, len(FEATURE_NAMES)]))]
    onnx_model = convert_sklearn(model, "decision_tree", initial_types)
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
            "accuracy": MetadataValue.float(accuracy),
            "s3_path": MetadataValue.text(s3_path),
            "format": MetadataValue.text("ONNX"),
            "model_size_bytes": MetadataValue.int(len(model_bytes)),
            "features": MetadataValue.text(", ".join(FEATURE_NAMES)),
            "samples": MetadataValue.int(len(X)),
            "tree_depth": MetadataValue.int(model.get_depth()),
        },
    )
