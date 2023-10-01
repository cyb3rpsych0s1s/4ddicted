//! healers
//!
//! - all healers are `ConsumableItem_Record`
//! - all healers can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Alcohol`)
//! - all healers triggers `Consume` but also a special `UseHealCharge` (`ObjectAction_Record`)

use red4ext_rs::types::ItemId;

use crate::interop::SubstanceId;

pub trait Healer {
    /// is this a MaxDOC ?
    fn is_maxdoc(&self) -> bool;
    /// is this a BounceBack ?
    fn is_bounceback(&self) -> bool;
    /// is this a Health Booster ?
    fn is_healthbooster(&self) -> bool;
    /// is this a healer ?
    fn is_healer(&self) -> bool {
        self.is_maxdoc() || self.is_bounceback() || self.is_healthbooster()
    }
}

/// all MaxDOC variants from vanilla game
///
/// There's also `Items.sts_wat_kab_01_inhaler`
/// a.k.a _Mike's inhaler_: not equipable, not consumable, is this of any use ?
pub const MAX_DOC: [SubstanceId; 12] = [
    SubstanceId::new("Items.CPO_FirstAidWhiff"),
    SubstanceId::new("Items.FirstAidWhiffV0"),
    SubstanceId::new("Items.FirstAidWhiffV1"),
    SubstanceId::new("Items.FirstAidWhiffV2"),
    SubstanceId::new("Items.FirstAidWhiffVCommonPlus"),
    SubstanceId::new("Items.FirstAidWhiffVEpic"),
    SubstanceId::new("Items.FirstAidWhiffVEpicPlus"),
    SubstanceId::new("Items.FirstAidWhiffVLegendaryPlus"),
    SubstanceId::new("Items.FirstAidWhiffVRarePlus"),
    SubstanceId::new("Items.FirstAidWhiffVUncommon"),
    SubstanceId::new("Items.FirstAidWhiffVUncommonPlus"),
    SubstanceId::new("Items.TTReanimatorTutorial"),
];

/// all BounceBack variants from vanilla game
pub const BOUNCE_BACK: [SubstanceId; 10] = [
    SubstanceId::new("Items.BonesMcCoy70V0"),
    SubstanceId::new("Items.BonesMcCoy70V1"),
    SubstanceId::new("Items.BonesMcCoy70V2"),
    SubstanceId::new("Items.BonesMcCoy70VCommonPlus"),
    SubstanceId::new("Items.BonesMcCoy70VEpic"),
    SubstanceId::new("Items.BonesMcCoy70VEpicPlus"),
    SubstanceId::new("Items.BonesMcCoy70VLegendaryPlus"),
    SubstanceId::new("Items.BonesMcCoy70VRarePlus"),
    SubstanceId::new("Items.BonesMcCoy70VUncommon"),
    SubstanceId::new("Items.BonesMcCoy70VUncommonPlus"),
];

/// all Health Booster variants from vanilla game
pub const HEALTH_BOOSTER: [SubstanceId; 2] = [
    SubstanceId::new("Items.HealthBooster"),
    SubstanceId::new("Items.Blackmarket_HealthBooster"),
];

impl Healer for ItemId {
    fn is_maxdoc(&self) -> bool {
        if let Ok(substance) = self.clone().try_into() {
            return MAX_DOC.contains(&substance);
        }
        false
    }

    fn is_bounceback(&self) -> bool {
        if let Ok(substance) = self.clone().try_into() {
            return BOUNCE_BACK.contains(&substance);
        }
        false
    }

    fn is_healthbooster(&self) -> bool {
        if let Ok(substance) = self.clone().try_into() {
            return HEALTH_BOOSTER.contains(&substance);
        }
        false
    }
}
