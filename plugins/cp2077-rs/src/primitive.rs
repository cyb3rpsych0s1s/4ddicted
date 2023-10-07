use red4ext_rs::prelude::{redscript_import, NativeRepr};

#[derive(Default, Clone)]
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

#[derive(Default, Clone)]
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

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct EulerAngles {
    roll: f32,
    pitch: f32,
    yaw: f32,
}

#[redscript_import]
impl EulerAngles {
    /// `public final static native func ToQuat(rotation: EulerAngles) -> Quaternion;`
    #[redscript(native)]
    pub fn to_quat(rotation: EulerAngles) -> Quaternion;
}

unsafe impl NativeRepr for EulerAngles {
    const NAME: &'static str = "EulerAngles";
}
