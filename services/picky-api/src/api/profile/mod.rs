//! Profile CRUD API routes.

use utoipa_axum::{router::OpenApiRouter, routes};

use crate::state::AppState;

mod create;
mod login;
mod model;
mod read;
mod update;

pub fn router(state: AppState) -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(create::handler))
        .routes(routes!(read::handler))
        .routes(routes!(update::handler))
        .routes(routes!(login::handler))
        .with_state(state)
}