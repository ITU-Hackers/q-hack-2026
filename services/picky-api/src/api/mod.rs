//! HTTP API router for the AI agent service.

use crate::state::AppState;

use utoipa_axum::{router::OpenApiRouter, routes};

pub mod chat;
pub mod profile;
pub mod recipes;
pub mod recommend;

pub fn router(state: AppState) -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(chat::handler))
        .routes(routes!(recommend::handler))
        .routes(routes!(recipes::list))
        .nest("/profile", profile::router(state.clone()))
        .with_state(state)
}
