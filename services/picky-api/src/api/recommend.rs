//! Recommendation handler: fetch profile → featurize → embed → Qdrant ANN search.

use axum::Json;
use axum::extract::{Path, Query, State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};
use qdrant_client::qdrant::SearchPointsBuilder;
use qdrant_client::qdrant::point_id::PointIdOptions;
use qdrant_client::qdrant::value::Kind;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

use crate::api::profile::model::ProfileRow;
use crate::config::CONFIG;
use crate::oapi::RECS_TAG;
use crate::profile_features;
use crate::state::{AppState, DbState, ModelState, QdrantState};

/// Query parameters for the `/recommend/{profile_id}` endpoint.
#[derive(Debug, Clone, Deserialize, ToSchema)]
pub struct RecommendQuery {
    /// Number of meals to return (default: 5).
    #[serde(default = "default_top_k")]
    #[schema(example = 5)]
    pub top_k: u32,
}

fn default_top_k() -> u32 {
    5
}

/// A single recommended meal returned by the endpoint.
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct RecommendedMeal {
    /// Qdrant point identifier.
    pub id: String,
    /// Dish name.
    pub dish: String,
    /// Cuisine region.
    pub region: String,
    /// List of ingredients.
    pub ingredients: Vec<String>,
    /// Similarity score from the ANN search.
    pub score: f32,
}

/// Response body for the `/recommend/{profile_id}` endpoint.
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct RecommendResponse {
    /// Recommended meals ordered by descending similarity score.
    pub meals: Vec<RecommendedMeal>,
}

#[utoipa::path(
    get,
    path = "/recommend/{profile_id}",
    tag = RECS_TAG,
    summary = "Get meal recommendations",
    description = "Given a profile ID, compute the user embedding via the \
    two-tower ONNX model and return the top-k nearest meals from Qdrant.",
    params(
        ("profile_id" = String, Path, description = "The profile UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"),
        ("top_k" = Option<u32>, Query, description = "Number of meals to return (default: 5)", example = 5),
    ),
    responses(
        (
            status = 200,
            description = "Meal recommendations",
            body = RecommendResponse,
            content_type = "application/json"
        ),
        (
            status = 400,
            description = "Invalid profile ID format",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
        (
            status = 404,
            description = "Profile not found",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
        (
            status = 503,
            description = "ONNX model not yet loaded",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
        (
            status = 500,
            description = "Inference or Qdrant search failed",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
    )
)]
#[axum::debug_handler(state = AppState)]
pub async fn handler(
    State(model_state): State<ModelState>,
    State(db): State<DbState>,
    State(qdrant): State<QdrantState>,
    Path(profile_id): Path<Uuid>,
    Query(query): Query<RecommendQuery>,
) -> HandlerResult<Json<RecommendResponse>> {
    // ── 1. Fetch profile from PostgreSQL ────────────────────────────────────
    let profile = sqlx::query_as!(
        ProfileRow,
        "SELECT id, email, password, adults, kids, dogs, cats, cuisines, \
         pref_fish, pref_pork, pref_beef, pref_dairy, pref_spicy, \
         restrictions, health_goal, cooking_time, budget \
         FROM profiles WHERE id = $1",
        profile_id
    )
    .fetch_optional(&db)
    .await
    .map_err(|e| {
        tracing::error!(
            error = %e,
            %profile_id,
            "Database query failed"
        );
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Database error",
            e.to_string(),
        )
    })?
    .ok_or_else(|| {
        HandlerError::new(
            StatusCode::NOT_FOUND,
            "Profile not found",
            format!("No profile with id {profile_id}"),
        )
    })?;

    // ── 2. Featurize profile → 128-dim vector ────────────────────────────────
    let user_vec: [f32; 128] = profile_features::featurize(&profile);

    // ── 3. Run ONNX user tower → 100-dim embedding ───────────────────────────
    let model_guard = model_state.load();
    let model = model_guard.as_ref().as_ref().ok_or_else(|| {
        HandlerError::new(
            StatusCode::SERVICE_UNAVAILABLE,
            "Model not loaded",
            "The ONNX user-tower model has not been loaded yet — please try again later",
        )
    })?;

    let embedding: [f32; 100] = model.embed_user(&user_vec).map_err(|e| {
        tracing::error!(error = %e, "ONNX user-tower inference failed");
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Inference failed",
            e.to_string(),
        )
    })?;

    // ── 4. Qdrant ANN search ─────────────────────────────────────────────────
    let query_vec: Vec<f32> = embedding.to_vec();
    let collection = CONFIG.QDRANT_COLLECTION.as_ref();

    let search_response = qdrant
        .search_points(
            SearchPointsBuilder::new(collection, query_vec, u64::from(query.top_k))
                .with_payload(true)
                .build(),
        )
        .await
        .map_err(|e| {
            tracing::error!(error = %e, collection, "Qdrant search failed");
            HandlerError::new(
                StatusCode::INTERNAL_SERVER_ERROR,
                "Search failed",
                e.to_string(),
            )
        })?;

    // ── 5. Map scored points → response ──────────────────────────────────────
    let meals: Vec<RecommendedMeal> = search_response
        .result
        .into_iter()
        .map(|point| {
            let payload = &point.payload;

            let dish = extract_string(payload, "dish");
            let region = extract_string(payload, "region");
            let ingredients = extract_string_list(payload, "ingredients");

            let id_str = match point.id.as_ref().and_then(|p| p.point_id_options.as_ref()) {
                Some(PointIdOptions::Uuid(s)) => s.clone(),
                Some(PointIdOptions::Num(n)) => n.to_string(),
                None => String::new(),
            };

            RecommendedMeal {
                id: id_str,
                dish,
                region,
                ingredients,
                score: point.score,
            }
        })
        .collect();

    Ok(Json(RecommendResponse { meals }))
}

// ── Payload extraction helpers ───────────────────────────────────────────────

fn extract_string(
    payload: &std::collections::HashMap<String, qdrant_client::qdrant::Value>,
    key: &str,
) -> String {
    payload
        .get(key)
        .and_then(|v| v.kind.as_ref())
        .and_then(|k| {
            if let Kind::StringValue(s) = k {
                Some(s.clone())
            } else {
                None
            }
        })
        .unwrap_or_default()
}

fn extract_string_list(
    payload: &std::collections::HashMap<String, qdrant_client::qdrant::Value>,
    key: &str,
) -> Vec<String> {
    payload
        .get(key)
        .and_then(|v| v.kind.as_ref())
        .and_then(|k| {
            if let Kind::ListValue(lv) = k {
                let items = lv
                    .values
                    .iter()
                    .filter_map(|v| v.kind.as_ref())
                    .filter_map(|k| {
                        if let Kind::StringValue(s) = k {
                            Some(s.clone())
                        } else {
                            None
                        }
                    })
                    .collect();
                Some(items)
            } else {
                None
            }
        })
        .unwrap_or_default()
}
