pub trait Category {
    fn category(&self) -> crate::interop::Category;
}
pub trait Quality {
    fn quality(&self) -> cp2077_rs::GameDataQuality;
}
mod private {
    pub trait Sealed {}
    impl Sealed for crate::interop::Category {}
    impl Sealed for cp2077_rs::GameDataQuality {}
}
pub trait Definable: private::Sealed {}
impl Definable for crate::interop::Category {}
impl Definable for cp2077_rs::GameDataQuality {}
pub trait Is<T: Definable> {
    fn is(&self, by: T) -> bool;
}
macro_rules! count_tts {
    () => { 0 };
    ($odd:tt $($a:tt $b:tt)*) => { (count_tts!($($a)*) << 1) | 1 };
    ($($a:tt $even:tt)*) => { count_tts!($($a)*) << 1 };
}
macro_rules! categories {
    ($trait: ident, $consumables: ident, $group_method: ident: {
        $($consumable: ident, $struct: ident, $method: ident: [$({ $id: literal }),+ $(,)?]),+ $(,)?
    }) => {
        pub trait $trait {
            $(fn $method(&self) -> bool;)+
            fn $group_method(&self) -> bool {
                $(self.$method() ||)+ false
            }
        }
        pub const $consumables: [crate::interop::SubstanceId; count_tts!($($($id)+)+)] = [
            $($(crate::interop::SubstanceId::new($id)),+),+
        ];
        $(
            pub const $consumable: [crate::interop::SubstanceId; count_tts!($($id)+)] = [
                $(crate::interop::SubstanceId::new($id)),+
            ]; 
        )+
        impl $trait for crate::interop::SubstanceId {
            $(fn $method(&self) -> bool { $consumable.contains(self) })+
        }
    };
}
categories!(
    Healer, HEALER, is_healer: {
        MAX_DOC, MaxDOC, is_maxdoc: [
            {"Items.CPO_FirstAidWhiff"},
            {"Items.FirstAidWhiffV0"},
            {"Items.FirstAidWhiffV1"},
            {"Items.FirstAidWhiffV2"},
            {"Items.FirstAidWhiffVCommonPlus"},
            {"Items.FirstAidWhiffVEpic"},
            {"Items.FirstAidWhiffVEpicPlus"},
            {"Items.FirstAidWhiffVLegendaryPlus"},
            {"Items.FirstAidWhiffVRarePlus"},
            {"Items.FirstAidWhiffVUncommon"},
            {"Items.FirstAidWhiffVUncommonPlus"},
            {"Items.TTReanimatorTutorial"},
        ],
        BOUNCE_BACK, BounceBack, is_bounceback: [
            {"Items.BonesMcCoy70V0"},
            {"Items.BonesMcCoy70V1"},
            {"Items.BonesMcCoy70V2"},
            {"Items.BonesMcCoy70VCommonPlus"},
            {"Items.BonesMcCoy70VEpic"},
            {"Items.BonesMcCoy70VEpicPlus"},
            {"Items.BonesMcCoy70VLegendaryPlus"},
            {"Items.BonesMcCoy70VRarePlus"},
            {"Items.BonesMcCoy70VUncommon"},
            {"Items.BonesMcCoy70VUncommonPlus"},
        ],
        HEALTH_BOOSTER, HealthBooster, is_healthbooster: [
            {"Items.HealthBooster"},
            {"Items.Blackmarket_HealthBooster"},
        ],
    }
);
