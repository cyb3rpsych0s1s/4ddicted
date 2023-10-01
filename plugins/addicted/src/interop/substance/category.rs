use red4ext_rs::prelude::NativeRepr;

use super::Substance;

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
