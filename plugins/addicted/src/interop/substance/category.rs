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
                .iter()
                .chain(BOUNCE_BACK.iter())
                .chain(HEALTH_BOOSTER.iter())
                .map(Clone::clone)
                .collect::<Vec<_>>(),
            Category::Anabolics => STAMINA_BOOSTER
                .iter()
                .chain(CAPACITY_BOOSTER.iter())
                .map(Clone::clone)
                .collect::<Vec<_>>(),
            Category::Neuros => MEMORY_BOOSTER
                .iter()
                .chain(NEURO_BLOCKER.iter())
                .map(Clone::clone)
                .collect::<Vec<_>>(),
            Category::Alcohol => ALCOHOL.to_vec(),
            Category::BlackLace => BLACK_LACE.to_vec(),
        }
    }
}
