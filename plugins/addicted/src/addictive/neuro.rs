//! neuros
//!
//! - all neuros are `ConsumableItem_Record`
//! - all neuros can be identified through `ItemCategory()` (`gamedataItemCategory.Consumable`)
//! - all neuros triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

pub const BLACK_LACE: [TweakDbId; 2] = [
    TweakDbId::new("Items.BlackLaceV0"),
    TweakDbId::new("Items.BlackLaceV1"),
];

/// specific to WannabeEdgerunner
pub const NEURO_BLOCKER: [TweakDbId; 3] = [
    TweakDbId::new("Items.ripperdoc_med"),
    TweakDbId::new("Items.ripperdoc_med_common"),
    TweakDbId::new("Items.ripperdoc_med_uncommon"),
];

pub trait Neuro {
    fn is_neuro(&self) -> bool {
        self.is_blacklace() || self.is_neuroblocker() || todo!()
    }
    fn is_blacklace(&self) -> bool;
    fn is_neuroblocker(&self) -> bool;
}

impl Neuro for ItemId {
    fn is_blacklace(&self) -> bool {
        BLACK_LACE.contains(&self.get_tdbid())
    }
    fn is_neuroblocker(&self) -> bool {
        NEURO_BLOCKER.contains(&self.get_tdbid())
    }
}
