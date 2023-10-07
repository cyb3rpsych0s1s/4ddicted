use red4ext_rs::prelude::NativeRepr;

#[repr(C)]
pub struct Vector4 {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
}

unsafe impl NativeRepr for Vector4 {
    const NAME: &'static str = "Vector4";
}

#[repr(C)]
pub struct Quaternion {
    i: f32,
    j: f32,
    k: f32,
    r: f32,
}

unsafe impl NativeRepr for Quaternion {
    const NAME: &'static str = "Quaternion";
}
