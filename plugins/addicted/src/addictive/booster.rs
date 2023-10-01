//! boosters
//!
//! - all boosters are `ConsumableItem_Record`
//! - all boosters can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Booster` and so on)
//! - all boosters triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::ItemId;

use crate::interop::SubstanceId;

pub const MEMORY_BOOSTER: [SubstanceId; 2] = [
    SubstanceId::new("Items.MemoryBooster"),
    SubstanceId::new("Items.Blackmarket_MemoryBooster"),
];

pub const STAMINA_BOOSTER: [SubstanceId; 2] = [
    SubstanceId::new("Items.StaminaBooster"),
    SubstanceId::new("Items.Blackmarket_StaminaBooster"),
];

pub const CAPACITY_BOOSTER: [SubstanceId; 2] = [
    SubstanceId::new("Items.CarryCapacityBooster"),
    SubstanceId::new("Items.Blackmarket_CarryCapacityBooster"),
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
        if let Ok(substance) = self.clone().try_into() {
            return STAMINA_BOOSTER.contains(&substance);
        }
        false
    }

    fn is_capacity_booster(&self) -> bool {
        if let Ok(substance) = self.clone().try_into() {
            return CAPACITY_BOOSTER.contains(&substance);
        }
        false
    }

    fn is_memory_booster(&self) -> bool {
        if let Ok(substance) = self.clone().try_into() {
            return MEMORY_BOOSTER.contains(&substance);
        }
        false
    }
}
