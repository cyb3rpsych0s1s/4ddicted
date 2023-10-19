//! addictive consumables
//!
//! Addictive consumables can be identified different ways.
//!
//! All are processed through `ItemActionsHelper.ProcessItemAction(...)`.

mod healer;
use cp2077_rs::GameDataQuality;
pub use healer::*;
mod booster;
pub use booster::*;
mod neuro;
pub use neuro::*;
mod alcohol;
pub use alcohol::*;

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::interop::{Category, Kind, SubstanceId, Tier};

/// indicates whether something can be considered as addictive or not.
pub trait Addictive {
    fn addictive(&self) -> bool;
}

impl Addictive for ItemId {
    fn addictive(&self) -> bool {
        self.get_tdbid().addictive()
    }
}

impl Addictive for TweakDbId {
    fn addictive(&self) -> bool {
        self.is_healer() || self.is_booster() || self.is_neuro() || self.is_alcoholic() || todo!()
    }
}

impl Addictive for SubstanceId {
    fn addictive(&self) -> bool {
        true
    }
}

pub trait Details {
    fn tier(&self) -> Tier;
    fn quality(&self) -> GameDataQuality;
    fn category(&self) -> Category;
    fn kind(&self) -> Kind;
}
