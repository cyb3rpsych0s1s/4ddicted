//! addictive consumables
//!
//! Addictive consumables can be identified different ways.
//!
//! All are processed through `ItemActionsHelper.ProcessItemAction(...)`.

mod healer;
pub use healer::*;
mod booster;
pub use booster::*;
mod neuro;
pub use neuro::*;
mod alcohol;
pub use alcohol::*;

use red4ext_rs::types::ItemId;

use crate::interop::SubstanceId;

/// indicates whether something can be considered as addictive or not.
pub trait Addictive {
    fn addictive(&self) -> bool;
}

impl Addictive for ItemId {
    fn addictive(&self) -> bool {
        self.is_healer() || self.is_booster() || self.is_neuro() || self.is_alcoholic() || todo!()
    }
}

impl Addictive for SubstanceId {
    fn addictive(&self) -> bool {
        true
    }
}
