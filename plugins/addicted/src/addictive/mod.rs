mod healer;
pub use healer::*;
mod booster;
pub use booster::*;
mod neuro;
pub use neuro::*;

use red4ext_rs::types::ItemId;

use crate::interop::SubstanceId;

pub trait Addictive {
    fn addictive(&self) -> bool;
}

impl Addictive for ItemId {
    fn addictive(&self) -> bool {
        self.is_healer() || self.is_booster() || self.is_neuro() // || TODO ...
    }
}

impl Addictive for SubstanceId {
    fn addictive(&self) -> bool {
        true
    }
}
