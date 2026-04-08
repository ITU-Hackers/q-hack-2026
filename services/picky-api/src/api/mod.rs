//! HTTP API router for the AI agent service.

use crate::state::AppState;

use utoipa_axum::{router::OpenApiRouter, routes};

mod chat;
mod predict;
mod profile;

pub fn router(state: AppState) -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(chat::handler))
        .routes(routes!(predict::handler))
        .nest("/profile", profile::router(state.clone()))
        .with_state(state)
}