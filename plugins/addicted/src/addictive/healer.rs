//! healers
//!
//! - all healers are `ConsumableItem_Record`
//! - all healers can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Alcohol`)
//! - all healers triggers `Consume` but also a special `UseHealCharge` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

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
pub const MAX_DOC: [TweakDbId; 12] = [
    TweakDbId::new("Items.CPO_FirstAidWhiff"),
    TweakDbId::new("Items.FirstAidWhiffV0"),
    TweakDbId::new("Items.FirstAidWhiffV1"),
    TweakDbId::new("Items.FirstAidWhiffV2"),
    TweakDbId::new("Items.FirstAidWhiffVCommonPlus"),
    TweakDbId::new("Items.FirstAidWhiffVEpic"),
    TweakDbId::new("Items.FirstAidWhiffVEpicPlus"),
    TweakDbId::new("Items.FirstAidWhiffVLegendaryPlus"),
    TweakDbId::new("Items.FirstAidWhiffVRarePlus"),
    TweakDbId::new("Items.FirstAidWhiffVUncommon"),
    TweakDbId::new("Items.FirstAidWhiffVUncommonPlus"),
    TweakDbId::new("Items.TTReanimatorTutorial"),
];

/// all BounceBack variants from vanilla game
pub const BOUNCE_BACK: [TweakDbId; 10] = [
    TweakDbId::new("Items.BonesMcCoy70V0"),
    TweakDbId::new("Items.BonesMcCoy70V1"),
    TweakDbId::new("Items.BonesMcCoy70V2"),
    TweakDbId::new("Items.BonesMcCoy70VCommonPlus"),
    TweakDbId::new("Items.BonesMcCoy70VEpic"),
    TweakDbId::new("Items.BonesMcCoy70VEpicPlus"),
    TweakDbId::new("Items.BonesMcCoy70VLegendaryPlus"),
    TweakDbId::new("Items.BonesMcCoy70VRarePlus"),
    TweakDbId::new("Items.BonesMcCoy70VUncommon"),
    TweakDbId::new("Items.BonesMcCoy70VUncommonPlus"),
];

/// all Health Booster variants from vanilla game
pub const HEALTH_BOOSTER: [TweakDbId; 2] = [
    TweakDbId::new("Items.HealthBooster"),
    TweakDbId::new("Items.Blackmarket_HealthBooster"),
];

impl Healer for ItemId {
    fn is_maxdoc(&self) -> bool {
        MAX_DOC.contains(&self.get_tdbid())
    }

    fn is_bounceback(&self) -> bool {
        BOUNCE_BACK.contains(&self.get_tdbid())
    }

    fn is_healthbooster(&self) -> bool {
        HEALTH_BOOSTER.contains(&self.get_tdbid())
    }
}
