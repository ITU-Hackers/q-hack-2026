//! Background service that watches for ONNX model updates on S3.
//!
//! Polls S3 periodically and hot-swaps the [`OnnxModel`] in [`ModelState`]
//! whenever the remote file changes, allowing zero-downtime model updates.

use std::sync::Arc;
use std::time::Duration;

use arc_swap::ArcSwap;
use aws_sdk_s3::error::SdkError;

use crate::model::OnnxModel;

/// Shared, atomically-swappable model state.
///
/// - `None` means no model has been loaded yet.
/// - Readers call [`ArcSwap::load`] for a lock-free snapshot.
/// - The watcher calls [`ArcSwap::store`] to swap in a new model.
pub type SharedModel = Arc<ArcSwap<Option<OnnxModel>>>;

/// Default polling interval for the model watcher.
const DEFAULT_POLL_INTERVAL: Duration = Duration::from_secs(30);

/// Spawn the model-watcher background task.
///
/// Returns the [`SharedModel`] handle that the rest of the application
/// (handlers, agent tools) should read from, and a [`tokio::task::JoinHandle`]
/// for the background polling loop.
///
/// The watcher will immediately attempt to load the model on startup, then poll
/// every `poll_interval` (or [`DEFAULT_POLL_INTERVAL`] if `None`).
pub fn spawn(
    s3_client: aws_sdk_s3::Client,
    bucket: String,
    key: String,
    poll_interval: Option<Duration>,
) -> (SharedModel, tokio::task::JoinHandle<()>) {
    let shared = Arc::new(ArcSwap::from_pointee(None));
    let shared_clone = Arc::clone(&shared);
    let interval = poll_interval.unwrap_or(DEFAULT_POLL_INTERVAL);

    let handle = tokio::spawn(async move {
        run_poll_loop(s3_client, bucket, key, shared_clone, interval).await;
    });

    (shared, handle)
}

/// The inner polling loop.
///
/// Runs indefinitely, checking S3 for ETag changes and reloading when needed.
async fn run_poll_loop(
    s3_client: aws_sdk_s3::Client,
    bucket: String,
    key: String,
    shared: SharedModel,
    interval: Duration,
) {
    let mut last_etag: Option<String> = None;

    loop {
        match check_and_reload(&s3_client, &bucket, &key, &shared, &mut last_etag).await {
            Ok(reloaded) => {
                if reloaded {
                    tracing::info!(bucket, key, etag = ?last_etag, "Model hot-swapped successfully");
                } else {
                    tracing::trace!(bucket, key, "Model unchanged, skipping reload");
                }
            }
            Err(e) => {
                tracing::warn!(
                    bucket,
                    key,
                    error = %e,
                    error_debug = ?e,
                    "Model watcher poll failed — will retry next interval"
                );
            }
        }

        tokio::time::sleep(interval).await;
    }
}

/// Check the remote ETag and reload the model if it changed.
///
/// Returns `Ok(true)` if a new model was loaded, `Ok(false)` if unchanged.
async fn check_and_reload(
    s3_client: &aws_sdk_s3::Client,
    bucket: &str,
    key: &str,
    shared: &SharedModel,
    last_etag: &mut Option<String>,
) -> anyhow::Result<bool> {
    // HEAD the object to get current ETag without downloading the body.
    let head = s3_client.head_object().bucket(bucket).key(key).send().await;

    let head = match head {
        Ok(h) => h,
        Err(e) => {
            // HeadObject on a missing key returns HTTP 404, but since HEAD
            // responses carry no body the SDK cannot parse it into a typed
            // error variant — it surfaces as `SdkError::ServiceError` with an
            // unhandled code, or in some SDK versions as
            // `SdkError::ResponseError`.  Check the raw HTTP status instead.
            let is_not_found = match &e {
                SdkError::ServiceError(ctx) => ctx.raw().status().as_u16() == 404,
                SdkError::ResponseError(ctx) => ctx.raw().status().as_u16() == 404,
                _ => false,
            };

            if is_not_found {
                tracing::debug!(
                    bucket,
                    key,
                    "Model object not found in S3 — waiting for upload"
                );
                return Ok(false);
            }
            // Preserve the full SdkError (connection, dispatch, service, etc.)
            // so logs show the real root cause (e.g. DNS failure, bad creds).
            return Err(anyhow::anyhow!(
                "S3 HeadObject failed (bucket={bucket}, key={key}): {e:#}"
            ));
        }
    };

    let current_etag = head.e_tag().map(String::from);

    // If the ETag hasn't changed, skip.
    if current_etag.is_some() && current_etag == *last_etag {
        return Ok(false);
    }

    tracing::info!(
        bucket,
        key,
        old_etag = ?last_etag,
        new_etag = ?current_etag,
        "ETag changed — downloading new model"
    );

    // Download and load the new model.
    let model = OnnxModel::from_s3(s3_client, bucket, key).await?;

    // Atomically swap the model.
    shared.store(Arc::new(Some(model)));

    *last_etag = current_etag;

    Ok(true)
}
