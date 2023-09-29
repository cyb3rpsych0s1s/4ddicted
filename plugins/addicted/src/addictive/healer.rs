use red4ext_rs::types::{ItemId, TweakDbId};

pub const MAX_DOC: [TweakDbId; 10] = [
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
];

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

pub trait Healer {
    fn is_maxdoc(&self) -> bool;
    fn is_bounceback(&self) -> bool;
    fn is_healthbooster(&self) -> bool;
    fn is_healer(&self) -> bool {
        self.is_maxdoc() || self.is_bounceback() || self.is_healthbooster()
    }
}

impl Healer for ItemId {
    fn is_maxdoc(&self) -> bool {
        MAX_DOC.contains(&self.get_tdbid())
    }

    fn is_bounceback(&self) -> bool {
        BOUNCE_BACK.contains(&self.get_tdbid())
    }

    fn is_healthbooster(&self) -> bool {
        self.get_tdbid() == TweakDbId::new("Items.HealthBooster")
    }
}
