//! ONNX model loading and inference via ONNX Runtime.
//!
//! Downloads the two-tower user-tower model (exported from Keras via tf2onnx)
//! from S3 (MinIO) and evaluates it to produce a 100-dimensional user
//! embedding from a 128-dimensional user feature vector.

use std::sync::Mutex;

use anyhow::Context;
use ndarray::Array2;
use ort::session::Session;
use ort::value::Tensor;

/// An ONNX model loaded via ONNX Runtime for user-tower embedding inference.
///
/// The inner [`Session`] is wrapped in a [`Mutex`] because `Session::run`
/// requires `&mut self` in ort v2.0.0-rc.9+. The mutex keeps `embed_user`
/// callable through a shared `&self` reference, which is required by the
/// `ArcSwap<Option<OnnxModel>>` hot-swap pattern used elsewhere in the
/// codebase.
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

    /// Run the user tower and return a 100-dimensional embedding.
    ///
    /// Accepts a 128-dimensional user feature vector and returns the
    /// corresponding 100-dimensional embedding produced by the ONNX user tower.
    pub fn embed_user(&self, user_vector: &[f32; 128]) -> anyhow::Result<[f32; 100]> {
        let input_data = user_vector.to_vec();
        let input_array = Array2::from_shape_vec((1, 128), input_data)
            .context("Failed to create (1, 128) input array")?;

        let input_tensor =
            Tensor::from_array(input_array).context("Failed to create input tensor")?;

        let mut session = self
            .session
            .lock()
            .map_err(|e| anyhow::anyhow!("Session mutex poisoned: {e}"))?;

        let outputs = session
            .run(ort::inputs![input_tensor])
            .context("ONNX inference failed")?;

        let (shape, values) = outputs[0]
            .try_extract_tensor::<f32>()
            .context("Failed to extract f32 output tensor")?;

        anyhow::ensure!(
            shape.len() == 2
                && ((shape[0] == 1 && shape[1] == 100) || (shape[0] == 100 && shape[1] == 1)),
            "Unexpected output shape: expected [1, 100] or [100, 1], got {shape:?}"
        );

        anyhow::ensure!(
            values.len() == 100,
            "Output tensor length {}, expected 100",
            values.len()
        );

        let mut embedding = [0_f32; 100];
        embedding.copy_from_slice(values);

        Ok(embedding)
    }
}
