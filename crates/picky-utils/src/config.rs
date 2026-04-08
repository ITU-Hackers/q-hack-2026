//! Configurations utilities for applications.

/// A macro that generates a configuration struct.
///
/// The struct will have a field for each of the given idents given in the macro
/// and will have a `from_env` method to create it from environment variables.
///
/// # Example
///
/// Usage together with the [`crate::env`] module and a [`std::sync::LazyLock`].
///
/// ```ignore
/// use std::sync::LazyLock;
/// use picky_utils::{
///     generate_config,
///     env::{get_env, get_env_parse}
/// };
///
/// pub static CONFIG: LazyLock<Config> = LazyLock::new(|| {
///     Config::from_env().unwrap()
/// });
///
/// generate_config! {
///     ENV: String = get_env,
///     SOME_INTEGER: u32 = get_env_parse,
/// };
/// ```
#[macro_export]
macro_rules! generate_config {
    ($($name:ident: $type:ty = $func:tt),+) => {
        /// Configuration for the application.
        #[allow(non_snake_case)]
        pub struct Config {
            $(
                pub $name: $type,
            )+
        }

        impl Config {
            /// Generates a new [`Config`] from environment variables.
            ///
            /// Returns an error if any of the environment variables are missing
            /// or if parsing into its type fails.
            #[inline]
            pub fn from_env() -> picky_utils::env::Result<Config> {
                Ok(Config {
                    $(
                        $name: $func(stringify!($name))?,
                    )+
                })
            }
        }
    };
}
