//! Environment variables utilities for applications.
//!
//! This module provides convenient wrappers around [`std::env::var`] with
//! enhanced error handling and type conversion capabilities.
//!
//! # Examples
//!
//! ```ignore
//! use lerpz_utils::env::{get_env, get_env_parse};
//!
//! // Get a simple string value
//! let path = get_env("PATH").expect("PATH should be set");
//!
//! // Parse into a specific type
//! std::env::set_var("PORT", "8080");
//! let port: u16 = get_env_parse("PORT").expect("PORT should be a valid u16");
//! ```

use std::{ffi::OsStr, str::FromStr};

/// A type alias for handling results from this module.
///
/// This is a convenience alias for `Result<T, Error>` where [`Error`]
/// represents environment variable-specific errors.
pub type Result<T> = std::result::Result<T, Error>;

/// Errors that can occur when working with environment variables.
#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("environment variable \"{0}\" was not found")]
    NotFoundError(String),
    #[error("couldn't parse environment variable \"{0}\" into {1}")]
    ParseError(String, String),
}

/// Gets the value of an environment variable.
///
/// This is a wrapper around [`std::env::var`] that returns a more descriptive
/// error when the variable is not found.
///
/// # Examples
///
/// ```ignore
/// use lerpz_utils::env::get_env;
///
/// // Set a variable for this example
/// std::env::set_var("MY_VAR", "hello");
///
/// let value = get_env("MY_VAR").unwrap();
/// assert_eq!(value, "hello");
///
/// // This will return an error
/// let result = get_env("NONEXISTENT_VAR");
/// assert!(result.is_err());
/// ```
pub fn get_env<K>(key: K) -> Result<String>
where
    K: AsRef<OsStr> + Copy,
{
    std::env::var(key).map_err(|_| Error::NotFoundError(key.as_ref().to_string_lossy().to_string()))
}

/// Gets an environment variable and parses it into the specified type.
///
/// This function retrieves the environment variable and attempts to parse it
/// using the type's [`FromStr`] implementation. This is useful for converting
/// environment variables into numbers, booleans, or other types that implement
/// `FromStr`.
///
/// # Examples
///
/// ```ignore
/// use lerpz_utils::env::get_env_parse;
///
/// // Parse a number
/// std::env::set_var("PORT", "8080");
/// let port: u16 = get_env_parse("PORT").unwrap();
/// assert_eq!(port, 8080);
///
/// // Parse a boolean
/// std::env::set_var("DEBUG", "true");
/// let debug: bool = get_env_parse("DEBUG").unwrap();
/// assert!(debug);
///
/// // Invalid value returns ParseError
/// std::env::set_var("INVALID", "not_a_number");
/// let result: Result<i32, _> = get_env_parse("INVALID");
/// assert!(result.is_err());
/// ```
pub fn get_env_parse<K, T>(key: K) -> Result<T>
where
    K: AsRef<OsStr> + Copy,
    T: FromStr,
{
    let variable = get_env(key)?;
    variable.parse().map_err(|_| {
        Error::ParseError(
            key.as_ref().to_string_lossy().to_string(),
            std::any::type_name::<T>().to_string(),
        )
    })
}

/// Gets an environment variable and converts it into the specified type.
///
/// This function retrieves the environment variable and converts it using the
/// type's [`From<String>`] implementation. Unlike [`get_env_parse`], this
/// conversion is infallible and always succeeds (assuming the variable exists).
///
/// Use this when you have a type that can always be constructed from a
/// `String`, such as `PathBuf`, custom wrapper types, or other infallible
/// conversions.
///
/// # Examples
///
/// ```ignore
/// use std::path::PathBuf;
///
/// use lerpz_utils::env::get_env_from;
///
/// std::env::set_var("CONFIG_PATH", "/etc/config");
/// let path: PathBuf = get_env_from("CONFIG_PATH").unwrap();
/// assert_eq!(path, PathBuf::from("/etc/config"));
///
/// // Custom wrapper type
/// struct ApiKey(String);
/// impl From<String> for ApiKey {
///     fn from(s: String) -> Self {
///         ApiKey(s)
///     }
/// }
///
/// std::env::set_var("API_KEY", "secret123");
/// let key: ApiKey = get_env_from("API_KEY").unwrap();
/// ```
pub fn get_env_from<K, T>(key: K) -> Result<T>
where
    K: AsRef<OsStr> + Copy,
    T: From<String>,
{
    let variable = get_env(key)?;
    Ok(T::from(variable))
}
