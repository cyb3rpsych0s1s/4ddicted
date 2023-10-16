use red4ext_rs::{prelude::NativeRepr, types::{RedArray, TweakDbId}};

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct Increase {
    pub score: i32,
    pub when: f32,
}
unsafe impl NativeRepr for Increase {
    const NAME: &'static str = "Addicted.Increase";
}

#[derive(Default)]
#[repr(C)]
pub struct Decrease {
    pub which: u32,
    pub score: i32,
    pub doses: RedArray<f32>,
}
unsafe impl NativeRepr for Decrease {
    const NAME: &'static str = "Addicted.Decrease";
}

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct ConsumeOnce {
    pub id: TweakDbId,
    pub increase: Increase,
}
unsafe impl NativeRepr for ConsumeOnce {
    const NAME: &'static str = "Addicted.ConsumeOnce";
}

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct ConsumeAgain {
    pub which: u32,
    pub increase: Increase,
}
unsafe impl NativeRepr for ConsumeAgain {
    const NAME: &'static str = "Addicted.ConsumeAgain";
}

#[derive(Default)]
#[repr(C)]
pub struct WeanOff {
    pub decrease: RedArray<Decrease>,
}
unsafe impl NativeRepr for WeanOff {
    const NAME: &'static str = "Addicted.WeanOff";
}
