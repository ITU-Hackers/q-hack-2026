//! Feature engineering: converts a [`ProfileRow`] into a 128-dimensional
//! float vector suitable for the two-tower ONNX user tower.

use crate::api::profile::model::ProfileRow;

const RAW_DIMS: usize = 29;
const OUT_DIMS: usize = 128;

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

fn one_hot(value: &str, categories: &[&str], out: &mut [f32]) {
    for (slot, &cat) in out.iter_mut().zip(categories.iter()) {
        *slot = if value.eq_ignore_ascii_case(cat) {
            1.0
        } else {
            0.0
        };
    }
}

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
    let mut raw = [0_f32; RAW_DIMS];
    let mut cursor: usize = 0;

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

    raw[cursor] = (profile.adults as f32 / 6.0).min(1.0);
    cursor += 1;
    raw[cursor] = profile.kids as f32 / 4.0;
    cursor += 1;

    const HEALTH_GOALS: &[&str] = &["balanced", "mediterranean", "high-protein"];
    one_hot(
        &profile.health_goal,
        HEALTH_GOALS,
        &mut raw[cursor..cursor + 3],
    );
    cursor += 3;

    const COOKING_TIMES: &[&str] = &["quick", "moderate", "enthusiast"];
    one_hot(
        &profile.cooking_time,
        COOKING_TIMES,
        &mut raw[cursor..cursor + 3],
    );
    cursor += 3;

    const BUDGETS: &[&str] = &["budget", "moderate", "flexible"];
    one_hot(&profile.budget, BUDGETS, &mut raw[cursor..cursor + 3]);
    cursor += 3;

    const CUISINES: &[&str] = &[
        "Asian",
        "Italian",
        "French",
        "Mexican",
        "Indian",
        "Mediterranean",
        "American",
    ];
    multi_hot(&profile.cuisines, CUISINES, &mut raw[cursor..cursor + 7]);
    cursor += 7;

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

    debug_assert_eq!(cursor, RAW_DIMS, "raw feature dimension mismatch");

    let mut projected = [0_f32; OUT_DIMS];
    for (j, slot) in projected.iter_mut().enumerate() {
        let mut sum = 0_f32;
        for (i, &r) in raw.iter().enumerate() {
            sum += r * proj(i, j);
        }
        *slot = sum;
    }

    let norm: f32 = projected.iter().map(|&x| x * x).sum::<f32>().sqrt();
    if norm > 1e-10 {
        for v in &mut projected {
            *v /= norm;
        }
    }

    projected
}
