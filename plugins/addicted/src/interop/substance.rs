use red4ext_rs::prelude::NativeRepr;

/// represents all potentially addictive consumables found in-game.
#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
#[allow(dead_code)]
pub enum Substance {
    #[default]
    Unknown = -1,
    Alcohol = 1,
    MaxDOC = 2,     // FirstAidWhiff
    BounceBack = 3, // BonesMcCoy
    HealthBooster = 4,
    MemoryBooster = 5,
    StaminaBooster = 7,
    BlackLace = 8,
    CarryCapacityBooster = 9,
    NeuroBlocker = 10,
}

unsafe impl NativeRepr for Substance {
    const NAME: &'static str = "Addicted.Substance";
}
