//! boosters
//!
//! - all boosters are `ConsumableItem_Record`
//! - all boosters can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Booster` and so on)
//! - all boosters triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

pub const MEMORY_BOOSTER: [TweakDbId; 2] = [
    TweakDbId::new("Items.MemoryBooster"),
    TweakDbId::new("Items.Blackmarket_MemoryBooster"),
];

pub const STAMINA_BOOSTER: [TweakDbId; 2] = [
    TweakDbId::new("Items.StaminaBooster"),
    TweakDbId::new("Items.Blackmarket_StaminaBooster"),
];

pub const CAPACITY_BOOSTER: [TweakDbId; 2] = [
    TweakDbId::new("Items.CarryCapacityBooster"),
    TweakDbId::new("Items.Blackmarket_CarryCapacityBooster"),
];

pub trait Booster {
    fn is_booster(&self) -> bool {
        self.is_stamina_booster() || self.is_capacity_booster() || self.is_memory_booster()
    }
    fn is_stamina_booster(&self) -> bool;
    fn is_capacity_booster(&self) -> bool;
    fn is_memory_booster(&self) -> bool;
}

impl Booster for ItemId {
    fn is_stamina_booster(&self) -> bool {
        STAMINA_BOOSTER.contains(&self.get_tdbid())
    }

    fn is_capacity_booster(&self) -> bool {
        CAPACITY_BOOSTER.contains(&self.get_tdbid())
    }

    fn is_memory_booster(&self) -> bool {
        MEMORY_BOOSTER.contains(&self.get_tdbid())
    }
}
