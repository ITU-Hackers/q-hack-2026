//! HTTP API router for the AI agent service.

use crate::state::AppState;

use utoipa_axum::{router::OpenApiRouter, routes};

pub(crate) mod profile;

mod chat;
mod recommend;
mod profile;
mod recipes;

pub fn router(state: AppState) -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(chat::handler))
        .routes(routes!(recommend::handler))
        .routes(routes!(recipes::list))
        .nest("/profile", profile::router(state.clone()))
        .with_state(state)
}
