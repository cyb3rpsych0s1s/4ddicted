//! boosters
//!
//! - all boosters are `ConsumableItem_Record`
//! - all boosters can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Booster` and so on)
//! - all boosters triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::{interop::ContainsItem, reference};

reference!(
    name: MEMORY_BOOSTER, substance: MemoryBooster, kind: Mild, category: Neuros,
    [
        key: "Items.MemoryBooster", quality: Uncommon, effect: ("BaseStatusEffect.MemoryBooster"),
        key: "Items.Blackmarket_MemoryBooster", quality: Epic, effect: ("BaseStatusEffect.Blackmarket_MemoryBooster"),
    ]
);

reference!(
    name: STAMINA_BOOSTER, substance: StaminaBooster, kind: Mild, category: Anabolics,
    [
        key: "Items.StaminaBooster", quality: Uncommon, effect: ("BaseStatusEffect.StaminaBooster"),
        key: "Items.Blackmarket_StaminaBooster", quality: Epic, effect: ("BaseStatusEffect.Blackmarket_StaminaBooster"),
    ]
);

reference!(
    name: CAPACITY_BOOSTER, substance: CarryCapacityBooster, kind: Mild, category: Anabolics,
    [
        key: "Items.CarryCapacityBooster", quality: Uncommon, effect: ("BaseStatusEffect.CarryCapacityBooster"),
        key: "Items.Blackmarket_CarryCapacityBooster", quality: Epic, effect: ("BaseStatusEffect.Blackmarket_CarryCapacityBooster"),
    ]
);

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
        STAMINA_BOOSTER.contains_item(self)
    }

    fn is_capacity_booster(&self) -> bool {
        CAPACITY_BOOSTER.contains_item(self)
    }

    fn is_memory_booster(&self) -> bool {
        MEMORY_BOOSTER.contains_item(self)
    }
}

impl Booster for TweakDbId {
    fn is_stamina_booster(&self) -> bool {
        STAMINA_BOOSTER.contains_id(self)
    }

    fn is_capacity_booster(&self) -> bool {
        CAPACITY_BOOSTER.contains_id(self)
    }

    fn is_memory_booster(&self) -> bool {
        MEMORY_BOOSTER.contains_id(self)
    }
}
