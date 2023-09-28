use red4ext_rs::prelude::NativeRepr;

use crate::addictive::{
    ALCOHOL, BLACK_LACE, BOUNCE_BACK, CAPACITY_BOOSTER, HEALTH_BOOSTER, MAX_DOC, MEMORY_BOOSTER,
    NEURO_BLOCKER, STAMINA_BOOSTER,
};

use super::{Substance, SubstanceId};

#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
pub enum Category {
    #[default]
    Healers = 0,
    Anabolics = 1,
    Neuros = 2,
    Alcohol = 3,
    BlackLace = 4,
}

unsafe impl NativeRepr for Category {
    const NAME: &'static str = "Addicted.Category";
}

impl From<Category> for &[Substance] {
    fn from(value: Category) -> Self {
        match value {
            Category::Healers => &[
                Substance::MaxDOC,
                Substance::BounceBack,
                Substance::HealthBooster,
            ],
            Category::Anabolics => &[Substance::StaminaBooster, Substance::CarryCapacityBooster],
            Category::Neuros => &[Substance::MemoryBooster, Substance::NeuroBlocker],
            Category::Alcohol => &[Substance::Alcohol],
            Category::BlackLace => &[Substance::BlackLace],
        }
    }
}

impl From<Category> for Vec<SubstanceId> {
    fn from(value: Category) -> Self {
        match value {
            Category::Healers => MAX_DOC
                .keys()
                .chain(BOUNCE_BACK.keys())
                .chain(HEALTH_BOOSTER.keys())
                .cloned()
                .collect::<Vec<_>>(),
            Category::Anabolics => STAMINA_BOOSTER
                .keys()
                .chain(CAPACITY_BOOSTER.keys())
                .cloned()
                .collect::<Vec<_>>(),
            Category::Neuros => MEMORY_BOOSTER
                .keys()
                .chain(NEURO_BLOCKER.keys())
                .cloned()
                .collect::<Vec<_>>(),
            Category::Alcohol => ALCOHOL.keys().cloned().collect(),
            Category::BlackLace => BLACK_LACE.keys().cloned().collect(),
        }
    }
}
