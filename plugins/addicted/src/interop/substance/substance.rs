use red4ext_rs::prelude::NativeRepr;

use crate::addictive::{
    Alcoholic, Booster, Healer, Neuro, ALCOHOL, BLACK_LACE, BOUNCE_BACK, CAPACITY_BOOSTER,
    HEALTH_BOOSTER, MAX_DOC, MEMORY_BOOSTER, NEURO_BLOCKER, STAMINA_BOOSTER,
};

use super::{Category, SubstanceId};

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

impl SubstanceId {
    pub fn category(&self) -> Category {
        if self.is_alcoholic() {
            return Category::Alcohol;
        }
        if self.is_capacity_booster() || self.is_stamina_booster() {
            return Category::Anabolics;
        }
        if self.is_blacklace() {
            return Category::BlackLace;
        }
        if self.is_healer() {
            return Category::Healers;
        }
        if self.is_neuro() {
            return Category::Neuros;
        }
        unreachable!()
    }
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

impl From<Substance> for Vec<SubstanceId> {
    fn from(value: Substance) -> Self {
        match value {
            Substance::Alcohol => ALCOHOL.keys(),
            Substance::MaxDOC => MAX_DOC.keys(),
            Substance::BounceBack => BOUNCE_BACK.keys(),
            Substance::HealthBooster => HEALTH_BOOSTER.keys(),
            Substance::MemoryBooster => MEMORY_BOOSTER.keys(),
            Substance::StaminaBooster => STAMINA_BOOSTER.keys(),
            Substance::BlackLace => BLACK_LACE.keys(),
            Substance::CarryCapacityBooster => CAPACITY_BOOSTER.keys(),
            Substance::NeuroBlocker => NEURO_BLOCKER.keys(),
        }
        .cloned()
        .collect()
    }
}
