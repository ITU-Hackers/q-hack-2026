//! HTTP API router for the AI agent service.

use crate::state::AppState;

use utoipa_axum::{router::OpenApiRouter, routes};

mod chat;
pub(crate) mod profile;
mod recommend;

pub fn router(state: AppState) -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(chat::handler))
        .routes(routes!(recommend::handler))
        .nest("/profile", profile::router(state.clone()))
        .with_state(state)
}