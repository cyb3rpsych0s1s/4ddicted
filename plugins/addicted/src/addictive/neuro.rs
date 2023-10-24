//! neuros
//!
//! - all neuros are `ConsumableItem_Record`
//! - all neuros can be identified through `ItemCategory()` (`gamedataItemCategory.Consumable`)
//! - all neuros triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::{interop::ContainsItem, reference};

reference!(
    name: BLACK_LACE, substance: BlackLace, kind: Hard, category: BlackLace,
    [
        key: "Items.BlackLaceV0", quality: Rare, effect: ("BaseStatusEffect.BlackLaceV0"),
        key: "Items.BlackLaceV1", quality: Epic, effect: ("BaseStatusEffect.BlackLaceV1"),
    ]
);

// "specific to WannabeEdgerunner"
reference!(
    name: NEURO_BLOCKER, substance: BlackLace, kind: Hard, category: BlackLace,
    [
        key: "Items.ripperdoc_med", quality: Rare, effect: ("BaseStatusEffect.ripperdoc_med"),
        key: "Items.ripperdoc_med_common", quality: Common, effect: ("BaseStatusEffect.ripperdoc_med_common"),
        key: "Items.ripperdoc_med_uncommon", quality: Uncommon, effect: ("BaseStatusEffect.ripperdoc_med_uncommon"),
    ]
);

pub trait Neuro {
    fn is_neuro(&self) -> bool {
        self.is_blacklace() || self.is_neuroblocker()
    }
    fn is_blacklace(&self) -> bool;
    fn is_neuroblocker(&self) -> bool;
}

impl Neuro for ItemId {
    fn is_blacklace(&self) -> bool {
        BLACK_LACE.contains_item(self)
    }
    fn is_neuroblocker(&self) -> bool {
        NEURO_BLOCKER.contains_item(self)
    }
}

impl Neuro for TweakDbId {
    fn is_blacklace(&self) -> bool {
        BLACK_LACE.contains_id(self)
    }
    fn is_neuroblocker(&self) -> bool {
        NEURO_BLOCKER.contains_id(self)
    }
}
