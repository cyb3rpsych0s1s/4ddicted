use red4ext_rs::types::TweakDbId;

pub const HOUSING: [TweakDbId; 3] = [
    TweakDbId::new("HousingStatusEffect.Rested"),
    TweakDbId::new("HousingStatusEffect.Refreshed"),
    TweakDbId::new("HousingStatusEffect.Energized"),
];

pub trait Housing {
    fn is_housing(&self) -> bool;
}

impl Housing for TweakDbId {
    fn is_housing(&self) -> bool {
        HOUSING.contains(self)
    }
}
