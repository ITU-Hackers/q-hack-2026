//! ONNX model loading and inference via ONNX Runtime.
//!
//! Downloads a trained decision-tree model (exported as ONNX by `skl2onnx`)
//! from S3 (MinIO) and evaluates it for food-preference predictions using
//! the `ort` crate (official ONNX Runtime Rust bindings).

use std::sync::Mutex;

use anyhow::Context;
use ndarray::Array2;
use ort::session::Session;
use ort::value::Tensor;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

/// Input features for a food-preference prediction.
#[derive(Debug, Clone, Deserialize, JsonSchema, ToSchema)]
pub struct PredictFeatures {
    /// Whether the food is spicy (0.0 or 1.0).
    pub spicy: f32,
    /// Whether the food is sweet (0.0 or 1.0).
    pub sweet: f32,
    /// Whether the food is salty (0.0 or 1.0).
    pub salty: f32,
    /// Whether the food is warm (0.0 or 1.0).
    pub warm: f32,
}

/// Output of a food-preference prediction.
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct PredictOutput {
    /// Whether the user is predicted to like the food.
    pub liked: bool,
    /// Raw predicted class label (0 = dislike, 1 = like).
    pub label: i64,
}

/// An ONNX model loaded via ONNX Runtime for food-preference inference.
///
/// The inner [`Session`] is wrapped in a [`Mutex`] because
/// `Session::run` requires `&mut self` in ort v2.0.0-rc.12+. The mutex
/// keeps `predict` callable through a shared `&self` reference, which is
/// required by the `ArcSwap<Option<OnnxModel>>` hot-swap pattern used
/// elsewhere in the codebase.
pub struct OnnxModel {
    session: Mutex<Session>,
}

impl OnnxModel {
    /// Download the ONNX model from S3 and create an ONNX Runtime session.
    pub async fn from_s3(
        s3_client: &aws_sdk_s3::Client,
        bucket: &str,
        key: &str,
    ) -> anyhow::Result<Self> {
        tracing::info!(bucket, key, "Downloading ONNX model from S3");

        let resp = s3_client
            .get_object()
            .bucket(bucket)
            .key(key)
            .send()
            .await
            .context("Failed to download ONNX model from S3")?;

        let model_bytes = resp
            .body
            .collect()
            .await
            .context("Failed to read model bytes from S3 response")?
            .into_bytes();

        tracing::info!(
            size_bytes = model_bytes.len(),
            "ONNX model downloaded, creating ONNX Runtime session"
        );

        let session = Session::builder()
            .context("Failed to create ONNX Runtime session builder")?
            .commit_from_memory(&model_bytes)
            .context("Failed to load ONNX session from model bytes")?;

        tracing::info!("ONNX Runtime session created successfully");

        Ok(Self {
            session: Mutex::new(session),
        })
    }

    /// Run inference on the given food-preference features.
    pub fn predict(&self, features: &PredictFeatures) -> anyhow::Result<PredictOutput> {
        // Build a 1×4 input array: [spicy, sweet, salty, warm]
        let input_data = vec![features.spicy, features.sweet, features.salty, features.warm];
        let input_array = Array2::from_shape_vec((1, 4), input_data)
            .context("Failed to create input array")?;

        // Convert to an ort Tensor and run the ONNX model.
        let input_tensor =
            Tensor::from_array(input_array).context("Failed to create input tensor")?;

        let mut session = self
            .session
            .lock()
            .map_err(|e| anyhow::anyhow!("Session mutex poisoned: {e}"))?;

        let outputs = session
            .run(ort::inputs!["features" => input_tensor])
            .context("ONNX inference failed")?;

        // skl2onnx DecisionTreeClassifier produces two outputs:
        //   - "label": predicted class label (int64)
        //   - "probabilities": class probabilities
        // Extract the label from the first output.
        let label_output = outputs
            .get("label")
            .context("Label output not found in ONNX results")?;

        let (_, label_data) = label_output
            .try_extract_tensor::<i64>()
            .context("Failed to extract label tensor")?;

        let label = *label_data.first().context("Label tensor is empty")?;

        Ok(PredictOutput {
            liked: label == 1,
            label,
        })
    }
}