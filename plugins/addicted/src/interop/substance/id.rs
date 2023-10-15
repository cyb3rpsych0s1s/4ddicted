use red4ext_rs::{
    prelude::NativeRepr,
    types::{ItemId, TweakDbId},
};

use crate::{
    addictive::{
        Addictive, Alcoholic, Booster, Healer, Neuro, ALCOHOL, BLACK_LACE, BOUNCE_BACK,
        CAPACITY_BOOSTER, HEALTH_BOOSTER, MAX_DOC, MEMORY_BOOSTER, NEURO_BLOCKER, STAMINA_BOOSTER,
    },
    symptoms::WithdrawalSymptoms,
};

use super::{Kind, Substance};

#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(transparent)]
/// strongly-typed version of a TweakDbId:
/// ensures that the ID is actually an addictive substance.
pub struct SubstanceId(TweakDbId);

impl PartialEq<TweakDbId> for SubstanceId {
    fn eq(&self, other: &TweakDbId) -> bool {
        self.0.eq(other)
    }
}
impl PartialEq<SubstanceId> for TweakDbId {
    fn eq(&self, other: &SubstanceId) -> bool {
        self.eq(&other.0)
    }
}
impl PartialEq<SubstanceId> for ItemId {
    fn eq(&self, other: &SubstanceId) -> bool {
        self.get_tdbid().eq(&other.0)
    }
}
impl PartialEq<ItemId> for SubstanceId {
    fn eq(&self, other: &ItemId) -> bool {
        self.0.eq(&other.get_tdbid())
    }
}
pub trait ContainsItem {
    fn contains_item(&self, value: &ItemId) -> bool;
}
impl<const N: usize> ContainsItem for [SubstanceId; N] {
    fn contains_item(&self, value: &ItemId) -> bool {
        self.iter().any(|x| x.0 == value.get_tdbid())
    }
}

impl From<SubstanceId> for WithdrawalSymptoms {
    fn from(value: SubstanceId) -> Self {
        match Substance::from(value) {
            Substance::Alcohol => WithdrawalSymptoms::ALCOHOL,
            Substance::MaxDOC => WithdrawalSymptoms::MAXDOC,
            Substance::BounceBack => WithdrawalSymptoms::BOUNCEBACK,
            Substance::HealthBooster => WithdrawalSymptoms::HEALTHBOOSTER,
            Substance::MemoryBooster => WithdrawalSymptoms::MEMORYBOOSTER,
            Substance::StaminaBooster => WithdrawalSymptoms::STAMINABOOSTER,
            Substance::BlackLace => WithdrawalSymptoms::BLACKLACE,
            Substance::CarryCapacityBooster => WithdrawalSymptoms::CARRYCAPACITYBOOSTER,
            Substance::NeuroBlocker => WithdrawalSymptoms::NEUROBLOCKER,
        }
    }
}

impl SubstanceId {
    pub(crate) const fn new(str: &str) -> Self {
        Self(TweakDbId::new(str))
    }
    pub fn kind(&self) -> Kind {
        match true {
            _ if self.is_blacklace() || self.is_alcoholic() => Kind::Hard,
            _ => Kind::Mild,
        }
    }
    pub fn kicks_in(&self) -> i32 {
        match self.kind() {
            Kind::Hard => 2,
            Kind::Mild => 1,
        }
    }
    pub fn wean_off(&self) -> i32 {
        match self.kind() {
            Kind::Hard => 1,
            Kind::Mild => 2,
        }
    }
    pub fn into_inner(self) -> TweakDbId {
        self.0
    }
}

#[derive(Debug)]
pub enum Error {
    NonAddictive,
}

unsafe impl NativeRepr for SubstanceId {
    const NAME: &'static str = TweakDbId::NAME;
    const MANGLED_NAME: &'static str = TweakDbId::MANGLED_NAME;
    const NATIVE_NAME: &'static str = TweakDbId::NATIVE_NAME;
}

impl TryFrom<ItemId> for SubstanceId {
    type Error = Error;

    fn try_from(value: ItemId) -> Result<Self, Self::Error> {
        if value.addictive() {
            return Ok(Self(value.get_tdbid()));
        }
        Err(Error::NonAddictive)
    }
}

impl Healer for SubstanceId {
    fn is_maxdoc(&self) -> bool {
        MAX_DOC.contains(self)
    }

    fn is_bounceback(&self) -> bool {
        BOUNCE_BACK.contains(self)
    }

    fn is_healthbooster(&self) -> bool {
        HEALTH_BOOSTER.contains(self)
    }
}

impl Alcoholic for SubstanceId {
    fn is_alcoholic(&self) -> bool {
        ALCOHOL.contains(self)
    }
}

impl Booster for SubstanceId {
    fn is_stamina_booster(&self) -> bool {
        STAMINA_BOOSTER.contains(self)
    }

    fn is_capacity_booster(&self) -> bool {
        CAPACITY_BOOSTER.contains(self)
    }

    fn is_memory_booster(&self) -> bool {
        MEMORY_BOOSTER.contains(self)
    }
}

impl Neuro for SubstanceId {
    fn is_blacklace(&self) -> bool {
        BLACK_LACE.contains(self)
    }

    fn is_neuroblocker(&self) -> bool {
        NEURO_BLOCKER.contains(self)
    }
}
