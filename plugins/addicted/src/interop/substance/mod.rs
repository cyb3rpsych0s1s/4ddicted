use red4ext_rs::prelude::NativeRepr;

mod id;
pub use id::*;
mod category;
pub use category::*;
mod kind;
pub use kind::*;
mod r#type;
pub use r#type::*;
mod quality;
pub use quality::*;
mod tier;
pub use tier::*;

use crate::addictive::{Alcoholic, Booster, Healer, Neuro};

/// represents all potentially addictive consumables found in-game.
#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
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
            _ => Self::Unknown,
        }
    }
}
