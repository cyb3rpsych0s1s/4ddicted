use red4ext_rs::{
    prelude::NativeRepr,
    types::{ItemId, TweakDbId},
};

use crate::addictive::{
    Addictive, Alcoholic, Booster, Healer, Neuro, ALCOHOL, BLACK_LACE, BOUNCE_BACK,
    CAPACITY_BOOSTER, HEALTH_BOOSTER, MAX_DOC, MEMORY_BOOSTER, NEURO_BLOCKER, STAMINA_BOOSTER,
};

use super::Kind;

#[derive(Default, Clone, PartialEq)]
#[repr(transparent)]
/// strongly-typed version of a TweakDbId:
/// ensures that the ID is actually an addictive substance.
pub struct SubstanceId(TweakDbId);

impl SubstanceId {
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
}

pub enum Error {
    NonAddictive,
}

unsafe impl NativeRepr for SubstanceId {
    const NAME: &'static str = TweakDbId::NAME;
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
        MAX_DOC.contains(&self.0)
    }

    fn is_bounceback(&self) -> bool {
        BOUNCE_BACK.contains(&self.0)
    }

    fn is_healthbooster(&self) -> bool {
        HEALTH_BOOSTER.contains(&self.0)
    }
}

impl Alcoholic for SubstanceId {
    fn is_alcoholic(&self) -> bool {
        ALCOHOL.contains(&self.0)
    }
}

impl Booster for SubstanceId {
    fn is_stamina_booster(&self) -> bool {
        STAMINA_BOOSTER.contains(&self.0)
    }

    fn is_capacity_booster(&self) -> bool {
        CAPACITY_BOOSTER.contains(&self.0)
    }

    fn is_memory_booster(&self) -> bool {
        MEMORY_BOOSTER.contains(&self.0)
    }
}

impl Neuro for SubstanceId {
    fn is_blacklace(&self) -> bool {
        BLACK_LACE.contains(&self.0)
    }

    fn is_neuroblocker(&self) -> bool {
        NEURO_BLOCKER.contains(&self.0)
    }
}
