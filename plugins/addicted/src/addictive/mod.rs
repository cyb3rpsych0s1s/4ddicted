mod healer;
pub use healer::*;

use red4ext_rs::{types::{TweakDbId, ItemId}, prelude::NativeRepr};

pub trait Addictive {
    fn addictive(&self) -> bool;
}

impl Addictive for ItemId {
    fn addictive(&self) -> bool {
        self.is_healer() // || ...
    }
}

impl Addictive for SubstanceId {
    fn addictive(&self) -> bool {
        true
    }
}
