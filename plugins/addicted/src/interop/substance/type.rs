use red4ext_rs::prelude::NativeRepr;

#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i32)]
#[allow(dead_code)]
pub enum ConsumableType {
    #[default]
    Drug = 0,
    Medical = 1,
    Count = 2,
    Invalid = 3,
}

unsafe impl NativeRepr for ConsumableType {
    const NAME: &'static str = "gamedataConsumableType";
}
