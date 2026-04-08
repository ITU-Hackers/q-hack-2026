//! Configuration module for the agent.

use std::{
    net::SocketAddr,
    sync::{Arc, LazyLock},
};

use http::HeaderValue;
use picky_utils::{
    env::{get_env_from, get_env_parse},
    generate_config, get_env,
};
use secrecy::SecretString;

/// The environment the server is running in.
#[derive(strum::EnumString, Debug, Clone, Copy, PartialEq, Eq)]
enum Env {
    #[strum(serialize = "production")]
    Production,
    #[strum(serialize = "development")]
    Development,
    #[strum(serialize = "test")]
    Test,
}

/// The main configuration struct for the agent.
///
/// Lazy loaded using [`LazyLock`] to ensure that the configuration is only
/// loaded once.
pub static CONFIG: LazyLock<Config> = LazyLock::new(|| Config::from_env().unwrap());

generate_config!(
    ENV: Env = get_env_parse,
    ADDR: SocketAddr = get_env_parse,
    ALLOWED_ORIGINS: HeaderValue = get_env_parse,
    PORTKEY_BASE_URL: Arc<str> = get_env_from,
    PORTKEY_PROVIDER: Arc<str> = get_env_from,
    PORTKEY_API_KEY: SecretString = get_env_from,
    TEXT_MODEL: Arc<str> = get_env_from,
    EMBEDDING_MODEL: Arc<str> = get_env_from,
    QDRANT_URL_HTTPS: Arc<str> = get_env_from,
    QDRANT_URL_GRPC: Arc<str> = get_env_from,
    QDRANT_COLLECTION: Arc<str> = get_env_from
);
