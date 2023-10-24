//! healers
//!
//! - all healers are `ConsumableItem_Record`
//! - all healers can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Alcohol`)
//! - all healers triggers `Consume` but also a special `UseHealCharge` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::{interop::ContainsItem, reference};

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

// all MaxDOC variants from vanilla game
//
// There's also `Items.sts_wat_kab_01_inhaler`
// a.k.a _Mike's inhaler_: not equipable, not consumable, is this of any use ?
reference!(
    name: MAX_DOC, substance: MaxDOC, kind: Mild, category: Healers,
    [
        key: "Items.FirstAidWhiffV0", quality: Common, effect: ("BaseStatusEffect.FirstAidWhiffV0", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffV0", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV0"),
        key: "Items.FirstAidWhiffVCommonPlus", quality: CommonPlus, effect: ("BaseStatusEffect.FirstAidWhiffV0", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffV0", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV0"),
        key: "Items.FirstAidWhiffVUncommon", quality: Uncommon, effect: ("BaseStatusEffect.FirstAidWhiffVUncommon", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffVUncommon", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffVUncommon"),
        key: "Items.FirstAidWhiffVUncommonPlus", quality: UncommonPlus, effect: ("BaseStatusEffect.FirstAidWhiffVUncommon", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffVUncommon", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffVUncommon"),
        key: "Items.FirstAidWhiffV1", quality: Rare, effect: ("BaseStatusEffect.FirstAidWhiffV1", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffV1", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV1"),
        key: "Items.FirstAidWhiffVRarePlus", quality: RarePlus, effect: ("BaseStatusEffect.FirstAidWhiffV1", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffV1", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV1"),
        key: "Items.FirstAidWhiffVEpic", quality: Epic, effect: ("BaseStatusEffect.FirstAidWhiffVEpic", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffVEpic", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffVEpic"),
        key: "Items.FirstAidWhiffVEpicPlus", quality: EpicPlus, effect: ("BaseStatusEffect.FirstAidWhiffVEpic", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffVEpic", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffVEpic"),
        key: "Items.FirstAidWhiffV2", quality: Legendary, effect: ("BaseStatusEffect.FirstAidWhiffV2", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffV2", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV2"),
        key: "Items.FirstAidWhiffVLegendaryPlus", quality: LegendaryPlus, effect: ("BaseStatusEffect.FirstAidWhiffV2", "BaseStatusEffect.NotablyWeakenedFirstAidWhiffV2", "BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV2"),
    ]
);

// all BounceBack variants from vanilla game
reference!(
    name: BOUNCE_BACK, substance: BounceBack, kind: Mild, category: Healers,
    [
        key: "Items.BonesMcCoy70V0", quality: Common, effect: ("BaseStatusEffect.BonesMcCoy70V0", "BaseStatusEffect.NotablyWeakenedBonesMcCoy70V0", "BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V0"),
        key: "Items.BonesMcCoy70VUncommon", quality: Uncommon, effect: ("BaseStatusEffect.BonesMcCoy70VUncommon", "BaseStatusEffect.NotablyWeakenedBonesMcCoy70VUncommon", "BaseStatusEffect.SeverelyWeakenedBonesMcCoy70VUncommon"),
        key: "Items.BonesMcCoy70VUncommonPlus", quality: UncommonPlus, effect: ("BaseStatusEffect.BonesMcCoy70VUncommon", "BaseStatusEffect.NotablyWeakenedBonesMcCoy70VUncommon", "BaseStatusEffect.SeverelyWeakenedBonesMcCoy70VUncommon"),
        key: "Items.BonesMcCoy70V1", quality: Rare, effect: ("BaseStatusEffect.BonesMcCoy70V1", "BaseStatusEffect.NotablyWeakenedBonesMcCoy70V1", "BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V1"),
        key: "Items.BonesMcCoyVRarePlus", quality: RarePlus, effect: ("BaseStatusEffect.BonesMcCoyV1", "BaseStatusEffect.NotablyWeakenedBonesMcCoyV1", "BaseStatusEffect.SeverelyWeakenedBonesMcCoyV1"),
        key: "Items.BonesMcCoyVEpic", quality: Epic, effect: ("BaseStatusEffect.BonesMcCoyVEpic", "BaseStatusEffect.NotablyWeakenedBonesMcCoyVEpic", "BaseStatusEffect.SeverelyWeakenedBonesMcCoyVEpic"),
        key: "Items.BonesMcCoyVEpicPlus", quality: EpicPlus, effect: ("BaseStatusEffect.BonesMcCoyVEpic", "BaseStatusEffect.NotablyWeakenedBonesMcCoyVEpic", "BaseStatusEffect.SeverelyWeakenedBonesMcCoyVEpic"),
        key: "Items.BonesMcCoy70V2", quality: Legendary, effect: ("BaseStatusEffect.BonesMcCoy70V2", "BaseStatusEffect.NotablyWeakenedBonesMcCoy70V2", "BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V2"),
        key: "Items.BonesMcCoy70VLegendaryPlus", quality: LegendaryPlus, effect: ("BaseStatusEffect.BonesMcCoy70V2", "BaseStatusEffect.NotablyWeakenedBonesMcCoy70V2", "BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V2"),
    ]
);

// all Health Booster variants from vanilla game
reference!(
    name: HEALTH_BOOSTER, substance: HealthBooster, kind: Mild, category: Healers,
    [
        key: "Items.HealthBooster", quality: Common, effect: ("BaseStatusEffect.HealthBooster", "BaseStatusEffect.NotablyWeakenedHealthBooster", "BaseStatusEffect.SeverelyWeakenedHealthBooster"),
        key: "Items.Blackmarket_HealthBooster", quality: Common, effect: ("BaseStatusEffect.Blackmarket_HealthBooster", "BaseStatusEffect.Blackmarket_NotablyWeakenedHealthBooster", "BaseStatusEffect.Blackmarket_SeverelyWeakenedHealthBooster"),
    ]
);

impl Healer for ItemId {
    fn is_maxdoc(&self) -> bool {
        MAX_DOC.contains_item(self)
    }

    fn is_bounceback(&self) -> bool {
        BOUNCE_BACK.contains_item(self)
    }

    fn is_healthbooster(&self) -> bool {
        HEALTH_BOOSTER.contains_item(self)
    }
}

impl Healer for TweakDbId {
    fn is_maxdoc(&self) -> bool {
        MAX_DOC.contains_id(self)
    }

    fn is_bounceback(&self) -> bool {
        BOUNCE_BACK.contains_id(self)
    }

    fn is_healthbooster(&self) -> bool {
        HEALTH_BOOSTER.contains_id(self)
    }
}
