//! Handler for reading a user profile by ID.

use axum::{
    Json,
    extract::{Path, State},
};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};
use uuid::Uuid;

use crate::oapi::PROFILE_TAG;
use crate::state::{AppState, DbState};

use super::model::{Profile, ProfileRow};

#[utoipa::path(
    get,
    path = "/{id}",
    tag = PROFILE_TAG,
    summary = "Get a profile by ID",
    description = "Retrieve a single user profile by its ID.",
    params(
        ("id" = String, Path, description = "The profile's UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"),
    ),
    responses(
        (
            status = 200,
            description = "The requested profile",
            body = Profile,
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
            status = 500,
            description = "Internal server error",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
    )
)]
#[axum::debug_handler(state = AppState)]
pub async fn handler(
    State(db): State<DbState>,
    Path(id): Path<String>,
) -> HandlerResult<Json<Profile>> {
    let uuid = Uuid::parse_str(&id).map_err(|_| {
        HandlerError::new(
            StatusCode::BAD_REQUEST,
            "Invalid profile ID",
            format!("'{id}' is not a valid UUID"),
        )
    })?;

    let row = sqlx::query_as!(ProfileRow, "SELECT * FROM profiles WHERE id = $1", uuid,)
        .fetch_optional(&db)
        .await
        .map_err(|e| {
            tracing::error!(error = %e, "Failed to query profile");
            HandlerError::new(
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to get profile",
                e.to_string(),
            )
        })?
        .ok_or_else(|| {
            HandlerError::new(
                StatusCode::NOT_FOUND,
                "Profile not found",
                format!("No profile with id '{id}'"),
            )
        })?;

    Ok(Json(Profile::from(row)))
}
