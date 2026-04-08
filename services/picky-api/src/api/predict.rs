//! Prediction handler for the food-preference ONNX model.

use axum::{Json, extract::State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};

use crate::model::{PredictFeatures, PredictOutput};
use crate::oapi::RECS_TAG;
use crate::state::{AppState, ModelState};

#[utoipa::path(
    post,
    path = "/predict",
    tag = RECS_TAG,
    summary = "Predict food preference",
    description = "Given food attributes (spicy, sweet, salty, warm), predict \
    whether the user will like it using the trained ONNX model.",
    request_body = PredictFeatures,
    responses(
        (
            status = 200,
            description = "Prediction result",
            body = PredictOutput,
            content_type = "application/json"
        ),
        (
            status = 500,
            description = "Inference failed",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
    )
)]
#[axum::debug_handler(state = AppState)]
pub async fn handler(
    State(model_state): State<ModelState>,
    Json(payload): Json<PredictFeatures>,
) -> HandlerResult<Json<PredictOutput>> {
    let model_guard = model_state.load();
    let model = model_guard.as_ref().as_ref().ok_or_else(|| {
        HandlerError::new(
            StatusCode::SERVICE_UNAVAILABLE,
            "Model not loaded",
            "The ONNX model has not been loaded yet — please try again later",
        )
    })?;

    let output = model.predict(&payload).map_err(|e| {
        dbg!(&e);
        tracing::error!(error = %e, "ONNX inference failed");
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Inference failed",
            e.to_string(),
        )
    })?;

    Ok(Json(output))
}
