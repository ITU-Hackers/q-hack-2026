//! OpenAPI documentation definition for the AI agent HTTP service.

use utoipa::openapi::SecurityRequirement;
use utoipa::openapi::security::{AuthorizationCode, Flow, OAuth2, Scopes, SecurityScheme};
use utoipa::{Modify, OpenApi};

use crate::config::CONFIG;

pub(crate) const AGENT_TAG: &str = "agent";
pub(crate) const VECTORIZE_TAG: &str = "vectorize";

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
        (name = VECTORIZE_TAG, description = "Recipe vectorization endpoints"),
    )
)]
pub(crate) struct ApiDoc;
