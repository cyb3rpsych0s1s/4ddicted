use std::mem::ManuallyDrop;

use red4ext_rs::{
    prelude::NativeRepr,
    types::{TweakDbId, RedArray},
};

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct Increase {
    pub score: i32,
    pub when: f32,
}
unsafe impl NativeRepr for Increase {
    const NAME: &'static str = "Increase";
}

#[derive(Default)]
#[repr(C)]
pub struct Decrease {
    pub which: u32,
    pub score: i32,
    pub doses: ManuallyDrop<RedArray<f32>>,
}
unsafe impl NativeRepr for Decrease {
    const NAME: &'static str = "Decrease";
}

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct ConsumeOnce {
    pub id: TweakDbId,
    pub increase: Increase,
}
unsafe impl NativeRepr for ConsumeOnce {
    const NAME: &'static str = "ConsumeOnce";
}

#[derive(Default, Clone, Copy)]
#[repr(C)]
pub struct ConsumeAgain {
    pub which: u32,
    pub increase: Increase,
}
unsafe impl NativeRepr for ConsumeAgain {
    const NAME: &'static str = "ConsumeAgain";
}

#[derive(Default)]
#[repr(C)]
pub struct WeanOff {
    pub decrease: ManuallyDrop<RedArray<Decrease>>,
}
unsafe impl NativeRepr for WeanOff {
    const NAME: &'static str = "WeanOff";
}
