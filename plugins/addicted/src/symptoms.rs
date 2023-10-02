use bitflags::bitflags;

use crate::interop::Substance;

bitflags! {
    #[derive(Clone, Copy, PartialEq, Eq)]
    #[repr(transparent)]
    pub struct WithdrawalSymptoms: u32 {
        const ALCOHOL              = 1 << (Substance::Alcohol as u8);
        const MAXDOC               = 1 << (Substance::MaxDOC as u8);
        const BOUNCEBACK           = 1 << (Substance::BounceBack as u8);
        const HEALTHBOOSTER        = 1 << (Substance::HealthBooster as u8);
        const MEMORYBOOSTER        = 1 << (Substance::MemoryBooster as u8);
        const STAMINABOOSTER       = 1 << (Substance::StaminaBooster as u8);
        const BLACKLACE            = 1 << (Substance::BlackLace as u8);
        const CARRYCAPACITYBOOSTER = 1 << (Substance::CarryCapacityBooster as u8);
        const NEUROBLOCKER         = 1 << (Substance::NeuroBlocker as u8);

        const HEALER   = Self::MAXDOC.bits() | Self::BOUNCEBACK.bits() | Self::HEALTHBOOSTER.bits();
        const ANABOLIC = Self::STAMINABOOSTER.bits() | Self::CARRYCAPACITYBOOSTER.bits();
        const NEURO    = Self::MEMORYBOOSTER.bits() | Self::NEUROBLOCKER.bits();
    }
}

impl WithdrawalSymptoms {
    pub const fn substance(&self) -> Option<Substance> {
        match self {
            &Self::ALCOHOL => Some(Substance::Alcohol),
            &Self::MAXDOC => Some(Substance::MaxDOC),
            &Self::BOUNCEBACK => Some(Substance::BounceBack),
            &Self::HEALTHBOOSTER => Some(Substance::HealthBooster),
            &Self::MEMORYBOOSTER => Some(Substance::MemoryBooster),
            &Self::STAMINABOOSTER => Some(Substance::StaminaBooster),
            &Self::BLACKLACE => Some(Substance::BlackLace),
            &Self::CARRYCAPACITYBOOSTER => Some(Substance::CarryCapacityBooster),
            &Self::NEUROBLOCKER => Some(Substance::NeuroBlocker),
            _ => None,
        }
    }
}
