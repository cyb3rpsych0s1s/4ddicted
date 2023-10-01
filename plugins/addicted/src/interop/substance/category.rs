use red4ext_rs::prelude::NativeRepr;

use super::{Substance, SubstanceId};

#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
pub enum Category {
    #[default]
    Healers = 0,
    Anabolics = 1,
    Neuros = 2,
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
        }
    }
}

impl From<Category> for &[SubstanceId] {
    fn from(value: Category) -> Self {
        todo!()
    }
}
