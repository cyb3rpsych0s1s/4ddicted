use red4ext_rs::prelude::redscript_global;

#[redscript_global(name = "ArrayPush")]
fn push_dose(arr: Vec<f32>, value: f32) -> ();