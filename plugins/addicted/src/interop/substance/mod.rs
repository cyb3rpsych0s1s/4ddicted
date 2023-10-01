use red4ext_rs::prelude::NativeRepr;

mod id;
pub use id::*;
mod category;
pub use category::*;
mod kind;
pub use kind::*;
mod r#type;
pub use r#type::*;
mod tier;
pub use tier::*;

use crate::addictive::{
    Alcoholic, Booster, Healer, Neuro, ALCOHOL, BLACK_LACE, BOUNCE_BACK, CAPACITY_BOOSTER,
    HEALTH_BOOSTER, MAX_DOC, MEMORY_BOOSTER, NEURO_BLOCKER, STAMINA_BOOSTER,
};

/// represents all potentially addictive consumables found in-game.
#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
pub enum Substance {
    #[default]
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

impl From<SubstanceId> for Substance {
    fn from(value: SubstanceId) -> Self {
        match true {
            _ if value.is_alcoholic() => Self::Alcohol,
            _ if value.is_maxdoc() => Self::MaxDOC,
            _ if value.is_bounceback() => Self::BounceBack,
            _ if value.is_healthbooster() => Self::HealthBooster,
            _ if value.is_memory_booster() => Self::MemoryBooster,
            _ if value.is_stamina_booster() => Self::StaminaBooster,
            _ if value.is_blacklace() => Self::BlackLace,
            _ if value.is_capacity_booster() => Self::CarryCapacityBooster,
            _ if value.is_neuroblocker() => Self::NeuroBlocker,
            _ => unreachable!(),
        }
    }
}

impl From<Substance> for Category {
    fn from(value: Substance) -> Self {
        match value {
            Substance::Alcohol => Category::Alcohol,
            Substance::MaxDOC => Category::Healers,
            Substance::BounceBack => Category::Healers,
            Substance::HealthBooster => Category::Healers,
            Substance::MemoryBooster => Category::Neuros,
            Substance::StaminaBooster => Category::Anabolics,
            Substance::BlackLace => Category::BlackLace,
            Substance::CarryCapacityBooster => Category::Anabolics,
            Substance::NeuroBlocker => Category::Neuros,
        }
    }
}

impl From<Substance> for &[SubstanceId] {
    fn from(value: Substance) -> Self {
        match value {
            Substance::Alcohol => &ALCOHOL,
            Substance::MaxDOC => &MAX_DOC,
            Substance::BounceBack => &BOUNCE_BACK,
            Substance::HealthBooster => &HEALTH_BOOSTER,
            Substance::MemoryBooster => &MEMORY_BOOSTER,
            Substance::StaminaBooster => &STAMINA_BOOSTER,
            Substance::BlackLace => &BLACK_LACE,
            Substance::CarryCapacityBooster => &CAPACITY_BOOSTER,
            Substance::NeuroBlocker => &NEURO_BLOCKER,
        }
    }
}
