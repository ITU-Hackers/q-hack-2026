//! Feature engineering: converts a [`ProfileRow`] into a 128-dimensional
//! float vector suitable for the two-tower ONNX user tower.
//!
//! # Pipeline
//! 1. Extract a 29-dimensional raw feature vector from the profile.
//! 2. Project it to 128 dimensions via a deterministic random projection.
//! 3. L2-normalise the projected vector.

use crate::api::profile::model::ProfileRow;

const RAW_DIMS: usize = 29;
const OUT_DIMS: usize = 128;

/// Deterministic pseudo-random projection value for matrix element M\[i\]\[j\].
///
/// Uses a three-round 64-bit finalisation mix so every `(i, j)` pair maps to
/// a stable value in \[-1.0, 1.0\] without storing the full matrix in memory.
fn proj(i: usize, j: usize) -> f32 {
    let mut x = (i as u64)
        .wrapping_mul(6_364_136_223_846_793_005)
        .wrapping_add(j as u64)
        .wrapping_mul(2_862_933_555_777_941_757)
        .wrapping_add(3_037_000_493);
    x ^= x >> 33;
    x = x.wrapping_mul(0xff51_afd7_ed55_8ccd);
    x ^= x >> 33;
    x = x.wrapping_mul(0xc4ce_b9fe_1a85_ec53);
    x ^= x >> 33;
    (x as f32 / u64::MAX as f32) * 2.0 - 1.0
}

/// Write a one-hot encoding of `value` into `out`.
///
/// `out.len()` must equal `categories.len()`.
fn one_hot(value: &str, categories: &[&str], out: &mut [f32]) {
    for (slot, &cat) in out.iter_mut().zip(categories.iter()) {
        *slot = if value.eq_ignore_ascii_case(cat) {
            1.0
        } else {
            0.0
        };
    }
}

/// Write a multi-hot encoding of `values` into `out`.
///
/// `out.len()` must equal `vocab.len()`.
fn multi_hot(values: &[String], vocab: &[&str], out: &mut [f32]) {
    for (slot, &cat) in out.iter_mut().zip(vocab.iter()) {
        *slot = if values.iter().any(|v| v.eq_ignore_ascii_case(cat)) {
            1.0
        } else {
            0.0
        };
    }
}

/// Convert a [`ProfileRow`] into a 128-dimensional unit-norm feature vector.
pub fn featurize(profile: &ProfileRow) -> [f32; OUT_DIMS] {
    // ── 1. Build 29-dim raw feature vector ──────────────────────────────────

    let mut raw = [0_f32; RAW_DIMS];
    let mut cursor: usize = 0;

    // Ingredient preferences normalised to [0, 1]  (5 dims)
    raw[cursor] = profile.pref_fish as f32 / 100.0;
    cursor += 1;
    raw[cursor] = profile.pref_pork as f32 / 100.0;
    cursor += 1;
    raw[cursor] = profile.pref_beef as f32 / 100.0;
    cursor += 1;
    raw[cursor] = profile.pref_dairy as f32 / 100.0;
    cursor += 1;
    raw[cursor] = profile.pref_spicy as f32 / 100.0;
    cursor += 1;
    // cursor = 5

    // Household size  (2 dims)
    raw[cursor] = (profile.adults as f32 / 6.0).min(1.0);
    cursor += 1;
    raw[cursor] = profile.kids as f32 / 4.0;
    cursor += 1;
    // cursor = 7

    // Health goal one-hot  (3 dims)
    const HEALTH_GOALS: &[&str] = &["balanced", "mediterranean", "high-protein"];
    one_hot(
        &profile.health_goal,
        HEALTH_GOALS,
        &mut raw[cursor..cursor + 3],
    );
    cursor += 3;
    // cursor = 10

    // Cooking time one-hot  (3 dims)
    const COOKING_TIMES: &[&str] = &["quick", "moderate", "enthusiast"];
    one_hot(
        &profile.cooking_time,
        COOKING_TIMES,
        &mut raw[cursor..cursor + 3],
    );
    cursor += 3;
    // cursor = 13

    // Budget one-hot  (3 dims)
    const BUDGETS: &[&str] = &["budget", "moderate", "flexible"];
    one_hot(&profile.budget, BUDGETS, &mut raw[cursor..cursor + 3]);
    cursor += 3;
    // cursor = 16

    // Cuisine multi-hot  (7 dims)
    const CUISINES: &[&str] = &[
        "Asian",
        "Italian",
        "French",
        "Mexican",
        "Indian",
        "Mediterranean",
        "American",
    ];
    multi_hot(
        &profile.cuisines,
        CUISINES,
        &mut raw[cursor..cursor + 7],
    );
    cursor += 7;
    // cursor = 23

    // Dietary restrictions multi-hot  (6 dims)
    const RESTRICTIONS: &[&str] = &[
        "nut-allergy",
        "gluten-free",
        "vegan",
        "vegetarian",
        "dairy-free",
        "halal",
    ];
    multi_hot(
        &profile.restrictions,
        RESTRICTIONS,
        &mut raw[cursor..cursor + 6],
    );
    cursor += 6;
    // cursor = 29

    debug_assert_eq!(cursor, RAW_DIMS, "raw feature dimension mismatch");

    // ── 2. Random projection: RAW_DIMS (29) → OUT_DIMS (128) ────────────────

    let mut projected = [0_f32; OUT_DIMS];
    for (j, slot) in projected.iter_mut().enumerate() {
        let mut sum = 0_f32;
        for (i, &r) in raw.iter().enumerate() {
            sum += r * proj(i, j);
        }
        *slot = sum;
    }

    // ── 3. L2 normalisation ──────────────────────────────────────────────────

    let norm: f32 = projected.iter().map(|&x| x * x).sum::<f32>().sqrt();
    if norm > 1e-10 {
        for v in &mut projected {
            *v /= norm;
        }
    }

    projected
}