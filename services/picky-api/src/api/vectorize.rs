//! POST /vectorize — turn a list of raw ingredient strings into a food2vec embedding.

use axum::{Json, extract::State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::food2vec;
use crate::oapi::VECTORIZE_TAG;
use crate::state::{AppState, EmbeddingMapState};

/// Vectorize request body.
#[derive(Debug, Deserialize, ToSchema)]
pub struct VectorizeRequest {
    /// Raw ingredient strings. Quantities and units are stripped automatically.
    ///
    /// Example: `["2 cups flour", "1 tsp salt", "3 large eggs"]`
    pub ingredients: Vec<String>,
}

/// Vectorize response body.
#[derive(Debug, Serialize, ToSchema)]
pub struct VectorizeResponse {
    /// Mean-pooled 100-dimensional recipe embedding.
    pub vector: Vec<f32>,
    /// Number of ingredients successfully matched in the food2vec vocabulary.
    pub matched: usize,
    /// Total number of input ingredients.
    pub total: usize,
}

/// Vectorize a recipe into a single food2vec embedding.
#[utoipa::path(
    post,
    path = "/vectorize",
    tag = VECTORIZE_TAG,
    summary = "Vectorize a recipe",
    description = "Convert a list of raw ingredient strings into a single 100-dimensional \
        embedding vector by mean-pooling food2vec ingredient vectors.\n\n\
        Quantities and units are stripped automatically \
        (e.g. `\"2 cups flour\"` → `\"flour\"`). \
        Unknown ingredients are skipped and reported in `total` but not `matched`.",
    request_body = VectorizeRequest,
    responses(
        (
            status = 200,
            description = "Recipe embedding",
            body = VectorizeResponse,
            content_type = "application/json"
        ),
        (
            status = 400,
            description = "Invalid request",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
        (
            status = 500,
            description = "Internal server error",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
    )
)]
#[axum::debug_handler(state = AppState)]
pub async fn handler(
    State(embeddings): State<EmbeddingMapState>,
    Json(payload): Json<VectorizeRequest>,
) -> Result<Json<VectorizeResponse>, HandlerError> {
    if payload.ingredients.is_empty() {
        return Err(HandlerError::new(
            StatusCode::BAD_REQUEST,
            "Ingredients list cannot be empty",
            "Provide at least one ingredient string",
        ));
    }

    let refs: Vec<&str> = payload.ingredients.iter().map(String::as_str).collect();
    let (vector, matched, total) = food2vec::vectorize(&embeddings, &refs);

    Ok(Json(VectorizeResponse {
        vector: vector.to_vec(),
        matched,
        total,
    }))
}
