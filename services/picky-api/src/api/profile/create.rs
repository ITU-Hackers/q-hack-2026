//! Handler for creating a new food preference profile.

use axum::{Json, extract::State};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema, HandlerResult};

use crate::oapi::PROFILE_TAG;
use crate::state::{AppState, DbState};

use super::model::{CreateProfile, Profile, ProfileRow};

#[utoipa::path(
    post,
    path = "/create",
    tag = PROFILE_TAG,
    summary = "Create a new profile",
    description = "Create a new user profile with household info, cuisine preferences, dietary restrictions, and more.",
    request_body = CreateProfile,
    responses(
        (
            status = 201,
            description = "Profile created successfully",
            body = Profile,
            content_type = "application/json"
        ),
        (
            status = 400,
            description = "Invalid request body",
            body = HandlerErrorSchema,
            content_type = "application/problem+json"
        ),
        (
            status = 409,
            description = "Email already exists",
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
    Json(payload): Json<CreateProfile>,
) -> HandlerResult<(StatusCode, Json<Profile>)> {
    let prefs = payload.preferences.unwrap_or_default();

    let row = sqlx::query_as!(
        ProfileRow,
        "INSERT INTO profiles (
            email, password, adults, kids, dogs, cats,
            cuisines, pref_fish, pref_pork, pref_beef, pref_dairy, pref_spicy,
            restrictions, health_goal, cooking_time, budget
         )
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
         RETURNING *",
        payload.email,
        payload.password,
        payload.adults,
        payload.kids,
        payload.dogs,
        payload.cats,
        &payload.cuisines,
        prefs.fish,
        prefs.pork,
        prefs.beef,
        prefs.dairy,
        prefs.spicy,
        &payload.restrictions,
        payload.health_goal,
        payload.cooking_time,
        payload.budget,
    )
    .fetch_one(&db)
    .await
    .map_err(|e| {
        if let sqlx::Error::Database(ref db_err) = e
            && db_err.is_unique_violation()
        {
            return HandlerError::new(
                StatusCode::CONFLICT,
                "Email already exists",
                format!("A profile with email '{}' already exists", payload.email),
            );
        }
        tracing::error!(error = %e, "Failed to insert profile");
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Failed to create profile",
            e.to_string(),
        )
    })?;

    Ok((StatusCode::CREATED, Json(Profile::from(row))))
}
