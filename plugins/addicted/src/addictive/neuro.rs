//! neuros
//!
//! - all neuros are `ConsumableItem_Record`
//! - all neuros can be identified through `ItemCategory()` (`gamedataItemCategory.Consumable`)
//! - all neuros triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::interop::{ContainsItem, SubstanceId};

pub const BLACK_LACE: [SubstanceId; 2] = [
    SubstanceId::new("Items.BlackLaceV0"),
    SubstanceId::new("Items.BlackLaceV1"),
];

/// specific to WannabeEdgerunner
pub const NEURO_BLOCKER: [SubstanceId; 3] = [
    SubstanceId::new("Items.ripperdoc_med"),
    SubstanceId::new("Items.ripperdoc_med_common"),
    SubstanceId::new("Items.ripperdoc_med_uncommon"),
];

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
