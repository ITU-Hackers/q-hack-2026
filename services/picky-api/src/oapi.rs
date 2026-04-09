//! OpenAPI documentation definition for the AI agent HTTP service.

use utoipa::openapi::SecurityRequirement;
use utoipa::openapi::security::{AuthorizationCode, Flow, OAuth2, Scopes, SecurityScheme};
use utoipa::{Modify, OpenApi};

use crate::config::CONFIG;

pub const AGENT_TAG: &str = "agent";
pub const RECS_TAG: &str = "recommendations";
pub const PROFILE_TAG: &str = "profiles";
pub const RECIPES_TAG: &str = "recipes";

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Picky AI Agent",
        description = "Picky AI Agent REST API",
        contact(
            email = "picky@picnic.com",
        ),
    ),
    tags(
        (name = AGENT_TAG, description = "AI agent chat endpoints"),
        (name = RECS_TAG, description = "Recommendation endpoints"),
        (name = PROFILE_TAG, description = "Food preference profile endpoints"),
        (name = RECIPES_TAG, description = "Recipe and ingredient endpoints"),
    )
)]
pub struct ApiDoc;