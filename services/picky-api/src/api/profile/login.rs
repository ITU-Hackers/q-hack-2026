//! Handler for logging in with email and password.

use axum::{Json, extract::State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};

use crate::oapi::PROFILE_TAG;
use crate::state::{AppState, DbState};

use super::model::{LoginRequest, Profile, ProfileRow};

#[utoipa::path(
    post,
    path = "/login",
    tag = PROFILE_TAG,
    summary = "Login with email and password",
    description = "Authenticate a user by email and password. Returns the full profile on success.",
    request_body = LoginRequest,
    responses(
        (
            status = 200,
            description = "Login successful",
            body = Profile,
            content_type = "application/json"
        ),
        (
            status = 401,
            description = "Invalid password",
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
    Json(payload): Json<LoginRequest>,
) -> HandlerResult<Json<Profile>> {
    let row = sqlx::query_as!(
        ProfileRow,
        "SELECT * FROM profiles WHERE email = $1",
        payload.email,
    )
    .fetch_optional(&db)
    .await
    .map_err(|e| {
        tracing::error!(error = %e, "Failed to query profile for login");
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Login failed",
            e.to_string(),
        )
    })?
    .ok_or_else(|| {
        HandlerError::new(
            StatusCode::NOT_FOUND,
            "Profile not found",
            format!("No profile with email '{}'", payload.email),
        )
    })?;

    if row.password != payload.password {
        return Err(HandlerError::new(
            StatusCode::UNAUTHORIZED,
            "Invalid password",
            "The password provided is incorrect".to_string(),
        ));
    }

    Ok(Json(Profile::from(row)))
}
