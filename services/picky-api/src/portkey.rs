//! Portkey gateway integration for `rig-core`.
//!
//! Portkey acts as an AI gateway that proxies requests to upstream LLM
//! providers (OpenAI, Anthropic, etc.) while adding observability, caching,
//! and routing features. It uses a standard OpenAI-compatible REST API but
//! requires two extra headers:
//!
//! - `x-portkey-api-key` — your Portkey workspace API key
//! - `x-portkey-provider` — the upstream provider to route to (e.g. `openai`)
//!
//! # Example
//!
//! ```ignore
//! use crate::config::CONFIG;
//! use crate::portkey::build_portkey_client;
//!
//! let client = build_portkey_client(
//!     &CONFIG.PORTKEY_BASE_URL,
//!     &CONFIG.PORTKEY_API_KEY,
//!     &CONFIG.PORTKEY_PROVIDER,
//! )?;
//!
//! let agent = client.agent(&CONFIG.DEFAULT_MODEL).build();
//! ```

use std::sync::Arc;

use http::HeaderMap;
use rig::providers::openai;
use secrecy::ExposeSecret;
use secrecy::SecretString;

pub fn build_portkey_client(
    api_base: &Arc<str>,
    api_key: &SecretString,
    provider: &Arc<str>,
) -> anyhow::Result<openai::Client> {
    let mut headers = HeaderMap::new();

    headers.insert(
        "x-portkey-api-key",
        api_key
            .expose_secret()
            .parse()
            .map_err(|e| anyhow::anyhow!("invalid x-portkey-api-key header value: {e}"))?,
    );

    headers.insert(
        "x-portkey-provider",
        provider
            .parse()
            .map_err(|e| anyhow::anyhow!("invalid x-portkey-provider header value: {e}"))?,
    );

    let client = openai::Client::builder()
        .api_key(api_key.expose_secret())
        .base_url(api_base.as_ref())
        .http_headers(headers)
        .build()
        .map_err(|e| anyhow::anyhow!("failed to build Portkey/rig client: {e}"))?;

    Ok(client)
}
