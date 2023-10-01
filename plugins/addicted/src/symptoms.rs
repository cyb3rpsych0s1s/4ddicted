use bitflags::bitflags;

use crate::interop::Substance;

bitflags! {
    #[derive(Clone, PartialEq)]
    #[repr(transparent)]
    pub struct WithdrawalSymptoms: u32 {
        const ALCOHOL       = 1 << Substance::Alcohol as u8;
        const MAXDOC        = 1 << Substance::MaxDOC as u8;
        const BOUNCEBACK    = 1 << Substance::BounceBack as u8;
        const HEALTHBOOSTER = 1 << Substance::HealthBooster as u8;

        const _ = 0;
        const HEALER = Self::MAXDOC.bits() | Self::BOUNCEBACK.bits() | Self::HEALTHBOOSTER.bits();
    }
}
