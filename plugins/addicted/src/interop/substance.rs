use red4ext_rs::{prelude::NativeRepr, types::{TweakDbId, ItemId}};

use crate::addictive::Addictive;

pub enum Error {
    NonAddictive,
}

/// strongly-typed version of a TweakDbId:
/// ensures that the ID is actually an addictive substance.
pub struct SubstanceId(TweakDbId);

unsafe impl NativeRepr for SubstanceId {
    const NAME: &'static str = TweakDbId::NAME;
    const NATIVE_NAME: &'static str = TweakDbId::NATIVE_NAME;
}

impl TryFrom<ItemId> for SubstanceId {
    type Error = Error;

    fn try_from(value: ItemId) -> Result<Self, Self::Error> {
        if value.addictive() { return Ok(Self(value.get_tdbid())); }
        Err(Error::NonAddictive)
    }
}

/// represents all potentially addictive consumables found in-game.
#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
#[allow(dead_code)]
pub enum Substance {
    #[default]
    Unknown = -1,
    Alcohol = 1,
    MaxDOC = 2,     // FirstAidWhiff
    BounceBack = 3, // BonesMcCoy
    HealthBooster = 4,
    MemoryBooster = 5,
    StaminaBooster = 7,
    BlackLace = 8,
    CarryCapacityBooster = 9,
    NeuroBlocker = 10,
}

unsafe impl NativeRepr for Substance {
    const NAME: &'static str = "Addicted.Substance";
}
