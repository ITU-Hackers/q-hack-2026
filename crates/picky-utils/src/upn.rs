//! Utilities for generating User Principal Names (UPNs).
//!
//! A UPN is an internet-style login name for user based identities. It is
//! commonly used in Microsoft environments, but can be used in other contexts
//! as well. This will often look like a mail address, but does not have to be
//! one.
//!
//! ### Globally unique identifier (GUID)
//!
//! Allowed characters are the English alphabet (a–z) and digits (0–9). The GUID
//! MUST always be lowercase. Special characters in names (such as `ø`, `é`, `ä`, `ß`)
//! should be normalized to their closest ASCII equivalents (e.g., `ø` → `o`, `é` → `e`)
//! before constructing the GUID. If there is no mapping in place for the special character,
//! it should be skipped.
//!
//! Format: `<x><y>.<w>@<domain>`
//!
//! Where:
//!
//! - **x** = first 2–3 letters of the user's first name
//! - **y** = first 2–3 letters of the user's last name (or middle name)
//! - **w** = the last 2 digits of the year the user was employed
//! - **domain** = the company's email domain (letters, digits, and `-` as allowed by normal DNS rules)
//!
//! Examples:
//! - Kasper Jønsson, Engineer - 15/11/2020 @ lerpz.com -> kasjon.20@lerpz.com

use std::borrow::Cow;

/// Errors that can occur when generating a UPN.
#[derive(thiserror::Error, Debug)]
#[non_exhaustive]
pub enum Error {
    #[error("Invalid department code")]
    DepartmentError,
    #[error(transparent)]
    FmtError(#[from] std::fmt::Error),
}

/// User information to generate a UPN for.
#[derive(Debug, Clone)]
pub struct UserInfo<'a> {
    pub forename: Cow<'a, str>,
    pub surnames: Vec<Cow<'a, str>>,
    pub hire_year: u32,
    pub domain: Cow<'a, str>,
}

impl<'a> UserInfo<'a> {
    pub fn new(
        forename: impl Into<Cow<'a, str>>,
        surnames: impl IntoIterator<Item = impl Into<Cow<'a, str>>>,
        hire_year: u32,
        domain: impl Into<Cow<'a, str>>,
    ) -> UserInfo<'a> {
        Self {
            forename: forename.into(),
            surnames: surnames.into_iter().map(Into::into).collect(),
            hire_year,
            domain: domain.into(),
        }
    }
}

/// Generate a UPN based on the provided user information.
///
/// This is a shorthand for [`generate_upn_with_iteration`] with iteration set to 0.
pub fn generate_upn<'a>(upn: impl Into<UserInfo<'a>>) -> Result<String, Error> {
    generate_upn_with_iteration(upn, 0)
}

/// Generate a UPN based on the provided user information and iteration number.
///
/// The iteration number is used to select which surname to use when the user
/// has multiple surnames. The iterator will start with the rightmost surname
/// and move leftwards as the iterations increas. If the iteration number
/// exceeds the number of surnames, it will wrap around to the rightmost surname.
///
/// ### Example:
///
/// ```ignore
/// let user_info = UserInfo {
///     forename: "Kasper",
///     surnames: vec!["Jønsson"],
///     hire_date: 2020,
///     domain: "lerpz.com",
/// };
///
/// let upn = generate_upn_with_iteration(user_info, 0).unwrap();
/// assert_eq!(upn, "kasjon.20@lerpz.com");
/// ```
pub fn generate_upn_with_iteration<'a>(
    upn: impl Into<UserInfo<'a>>,
    i: usize,
) -> Result<String, Error> {
    let upn: UserInfo = upn.into();
    let cap = 10 + upn.domain.len();
    let mut buf = String::with_capacity(cap);

    shortname(&upn.forename, &mut buf);

    let surname = get_surname(&upn.surnames, i);
    shortname(surname, &mut buf);

    buf.push('.');

    let year = upn.hire_year % 100;
    use std::fmt::Write;
    write!(&mut buf, "{year:02}")?;

    buf.push('@');
    buf.push_str(&upn.domain);

    Ok(buf)
}

/// Gets the the surnames based on the iteration.
///
/// This will start with the most right surname and move leftwards as the
/// iteration number increases. Then it resets to the rightmost surname and
/// continues.
#[inline]
fn get_surname<T>(surnames: &[T], iteration: usize) -> &T {
    let idx = surnames.len() - 1 - (iteration % surnames.len());
    &surnames[idx]
}

/// Replace non-allowed characters with an allowed equivalent.
#[inline]
pub fn replace_char(c: char) -> Option<char> {
    match c.to_ascii_lowercase() {
        lc if lc.is_ascii_lowercase() || lc.is_numeric() => Some(lc),
        'å' | 'æ' | 'ä' => Some('a'),
        'ø' | 'ö' => Some('o'),
        _ => None,
    }
}
/// Pushes the three first legal characters to buf.
#[inline]
fn shortname(name: &str, buf: &mut String) {
    for c in name.chars().filter_map(replace_char).take(3) {
        buf.push(c)
    }
}

#[cfg(test)]
mod tests {
    use crate::upn::{UserInfo, generate_upn, generate_upn_with_iteration};

    #[test]
    fn illegal_char() {
        let user_info = UserInfo::new("Kasper", vec!["Jønsson"], 2020, "lerpz.com");
        let upn = generate_upn(user_info).unwrap();
        assert_eq!(upn, "kasjon.20@lerpz.com");
    }

    #[test]
    fn surname_iterations() {
        let user_info = UserInfo::new(
            "Kasper",
            vec!["Sørensen", "Tørkilsen", "Jønsson"],
            2020,
            "lerpz.com",
        );

        let upn = generate_upn_with_iteration(user_info.clone(), 0).unwrap();
        assert_eq!(upn, "kasjon.20@lerpz.com");

        let upn = generate_upn_with_iteration(user_info.clone(), 1).unwrap();
        assert_eq!(upn, "kastor.20@lerpz.com");

        let upn = generate_upn_with_iteration(user_info.clone(), 2).unwrap();
        assert_eq!(upn, "kassor.20@lerpz.com");

        let upn = generate_upn_with_iteration(user_info.clone(), 3).unwrap();
        assert_eq!(upn, "kasjon.20@lerpz.com");

        let upn = generate_upn_with_iteration(user_info.clone(), 4).unwrap();
        assert_eq!(upn, "kastor.20@lerpz.com");

        let upn = generate_upn_with_iteration(user_info.clone(), 5).unwrap();
        assert_eq!(upn, "kassor.20@lerpz.com");
    }

    #[test]
    fn two_letter_names() {
        let user_info = UserInfo::new("bo", vec!["Bi"], 1995, "lerpz.com");

        let upn = generate_upn(user_info).unwrap();
        assert_eq!(upn, "bobi.95@lerpz.com");
    }
}
