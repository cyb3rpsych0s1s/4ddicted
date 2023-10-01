use red4ext_rs::types::TweakDbId;

const SLEEP: TweakDbId = TweakDbId::new("HousingStatusEffect.Rested");

pub const HOUSING: [TweakDbId; 3] = [
    SLEEP,
    TweakDbId::new("HousingStatusEffect.Refreshed"),
    TweakDbId::new("HousingStatusEffect.Energized"),
];

pub trait Housing {
    fn is_housing(&self) -> bool;
    fn is_sleep(&self) -> bool;
}

impl Housing for TweakDbId {
    fn is_housing(&self) -> bool {
        HOUSING.contains(self)
    }
    fn is_sleep(&self) -> bool {
        self == &SLEEP
    }
}
