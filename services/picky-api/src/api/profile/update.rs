//! Handler for updating a user profile.

use axum::{
    Json,
    extract::{Path, State},
};
use http::StatusCode;
use picky_axum::error::{HandlerError, HandlerErrorSchema};
use uuid::Uuid;

use crate::oapi::PROFILE_TAG;
use crate::state::{AppState, DbState};

use super::model::{Profile, ProfileRow, UpdateProfile};

#[utoipa::path(
    put,
    path = "/{id}",
    tag = PROFILE_TAG,
    summary = "Update a profile",
    description = "Update an existing user profile. Only provided fields are changed.",
    params(
        (
            "id" = String,
            Path,
            description = "The profile's UUID",
            example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        ),
    ),
    request_body = UpdateProfile,
    responses(
        (
            status = 200,
            description = "Profile updated successfully",
            body = Profile,
            content_type = "application/json"
        ),
        (
            status = 400,
            description = "Invalid request",
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
    Json(payload): Json<UpdateProfile>,
) -> Result<Json<Profile>, HandlerError> {
    let uuid = Uuid::parse_str(&id).map_err(|_| {
        HandlerError::new(
            StatusCode::BAD_REQUEST,
            "Invalid profile ID",
            format!("'{id}' is not a valid UUID"),
        )
    })?;

    // Flatten preference fields for the query.
    let pref_fish = payload.preferences.as_ref().map(|p| p.fish);
    let pref_pork = payload.preferences.as_ref().map(|p| p.pork);
    let pref_beef = payload.preferences.as_ref().map(|p| p.beef);
    let pref_dairy = payload.preferences.as_ref().map(|p| p.dairy);
    let pref_spicy = payload.preferences.as_ref().map(|p| p.spicy);

    let row = sqlx::query_as!(
        ProfileRow,
        "UPDATE profiles
         SET email        = COALESCE($2,  email),
             password     = COALESCE($3,  password),
             adults       = COALESCE($4,  adults),
             kids         = COALESCE($5,  kids),
             dogs         = COALESCE($6,  dogs),
             cats         = COALESCE($7,  cats),
             cuisines     = COALESCE($8,  cuisines),
             pref_fish    = COALESCE($9,  pref_fish),
             pref_pork    = COALESCE($10, pref_pork),
             pref_beef    = COALESCE($11, pref_beef),
             pref_dairy   = COALESCE($12, pref_dairy),
             pref_spicy   = COALESCE($13, pref_spicy),
             restrictions = COALESCE($14, restrictions),
             health_goal  = COALESCE($15, health_goal),
             cooking_time = COALESCE($16, cooking_time),
             budget       = COALESCE($17, budget)
         WHERE id = $1
         RETURNING *",
        uuid,
        payload.email,
        payload.password,
        payload.adults,
        payload.kids,
        payload.dogs,
        payload.cats,
        payload.cuisines.as_deref(),
        pref_fish,
        pref_pork,
        pref_beef,
        pref_dairy,
        pref_spicy,
        payload.restrictions.as_deref(),
        payload.health_goal,
        payload.cooking_time,
        payload.budget,
    )
    .fetch_optional(&db)
    .await
    .map_err(|e| {
        tracing::error!(error = %e, "Failed to update profile");
        HandlerError::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Failed to update profile",
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
