use std::borrow::Borrow;

use cp2077_rs::GameDataQuality;
use phf::PhfHash;

use crate::interop::{Category, EffectId, SubstanceId};

pub trait Definable {}
impl Definable for Category {}
impl Definable for GameDataQuality {}
impl Definable for (Category, GameDataQuality) {}
pub trait Is<T: Definable> {
    fn is(&self, by: T) -> bool;
}
const ITEMS_FIRST_AID_WHIFF_V0: SubstanceId = SubstanceId::new("a");
const ITEMS_FIRST_AID_WHIFF_V1: SubstanceId = SubstanceId::new("b");

impl Is<Category> for SubstanceId {
    fn is(&self, by: Category) -> bool {
        self.category().eq(&by)
    }
}
impl Is<GameDataQuality> for SubstanceId {
    fn is(&self, by: GameDataQuality) -> bool {
        self.quality().eq(&by)
    }
}

impl Is<(Category, GameDataQuality)> for SubstanceId {
    fn is(&self, by: (Category, GameDataQuality)) -> bool {
        (self.category(), self.quality()).eq(&by)
    }
}

impl SubstanceId {
    fn quality(&self) -> GameDataQuality {
        match self {
            &ITEMS_FIRST_AID_WHIFF_V0 => GameDataQuality::CommonPlus,
            &ITEMS_FIRST_AID_WHIFF_V1 => GameDataQuality::Rare,
            _ => todo!(),
        }
    }
}

impl Borrow<(u32, u8)> for SubstanceId {
    fn borrow(&self) -> &(u32, u8) {
        todo!()
    }
}
impl PhfHash for SubstanceId {
    fn phf_hash<H: std::hash::Hasher>(&self, _state: &mut H) {
        todo!()
    }
}

macro_rules! substance_id {
    ($($x: expr),+ $(,)?) => {
        $crate::interop::SubstanceId::new(::const_str::concat!("Items", ".", $($x),+))
    };
}
macro_rules! effect_id {
    ($($x: expr),+ $(,)?) => {
        $crate::interop::EffectId::new(::const_str::concat!("BaseStatusEffect", ".", $($x),+))
    };
}
macro_rules! def {
    ($c: expr, $q: expr, [$($x: expr),+ $(,)?]) => {
        &($c, $q, substance_id!($($x),+), effect_id!($($x),+))
    };
}
macro_rules! references {
    ($({ $d: pat => $c: expr, $q: expr, [$($x: expr),+ $(,)?] }),+ $(,)?) => {
        static REFERENCES: ::phf::Map<u64, &'static (Category, GameDataQuality, SubstanceId, EffectId)> = ::phf::phf_map! {
            $($d => def!($c, $q, [$($x),+])),+
        };
    };
}
macro_rules! constant {
    ($i:ident = [$($x: expr),+ $(,)?]) => {
        pub const $i: $crate::interop::SubstanceId = $crate::interop::SubstanceId::new(::const_str::concat!("Items", ".", $($x),+));
    };
}
macro_rules! structure {
    ($i:ident, $q: expr) => {
        pub struct $i;
        mod items {
            pub const $i: $crate::interop::SubstanceId = $crate::interop::SubstanceId::new(
                ::const_str::concat!("Items", ".", stringify!($i)),
            );
        }
        mod effects {
            pub const $i: $crate::interop::EffectId = $crate::interop::EffectId::new(
                ::const_str::concat!("BaseStatusEffect", ".", stringify!($i)),
            );
        }
        impl $i {
            #[inline]
            const fn quality(&self) -> ::cp2077_rs::GameDataQuality {
                $q
            }
            #[inline]
            const fn substance_id(&self) -> $crate::interop::SubstanceId {
                items::$i
            }
            #[inline]
            const fn effect_id(&self) -> $crate::interop::EffectId {
                effects::$i
            }
        }
    };
}
const FIRST_AID_WHIFF: &str = "FirstAidWhiff";
const V0: &str = "V0";
// static REFERENCES: ::phf::Map<u64, &'static (Category, GameDataQuality, SubstanceId, EffectId)> = phf::phf_map! {
//     1u64 => def!(Category::Healers, GameDataQuality::CommonPlus, [FIRST_AID_WHIFF, V0])
// };
references!(
    { 1u64 => Category::Healers, GameDataQuality::CommonPlus, [FIRST_AID_WHIFF, V0] },
    { 2u64 => Category::Healers, GameDataQuality::Rare, [FIRST_AID_WHIFF, "V1"] }
);
constant!(FIRST_AID_WHIFF_V0 = [FIRST_AID_WHIFF, V0]);
structure!(MaxDOC_V0, ::cp2077_rs::GameDataQuality::CommonPlus);

// pub trait Id<BY, ID> {
//     fn id(&self, by: BY) -> ID;
// }
// pub trait Ids<BY, ID> {
//     fn ids(&self, by: BY) -> Option<&[ID]>;
// }

// impl Ids<GameDataQuality, SubstanceId> for MaxDOC {
//     fn ids(&self, by: GameDataQuality) -> Option<&[SubstanceId]> {
//         match by {
//             GameDataQuality::Common => todo!(),
//             GameDataQuality::CommonPlus => todo!(),
//             GameDataQuality::Epic => todo!(),
//             GameDataQuality::EpicPlus => todo!(),
//             GameDataQuality::Iconic => todo!(),
//             GameDataQuality::Legendary => todo!(),
//             GameDataQuality::LegendaryPlus => todo!(),
//             GameDataQuality::LegendaryPlusPlus => todo!(),
//             GameDataQuality::Random => todo!(),
//             GameDataQuality::Rare => Some(&[SubstanceId::new("Items.FirstAidWhiffV1")]),
//             GameDataQuality::RarePlus => todo!(),
//             GameDataQuality::Uncommon => todo!(),
//             GameDataQuality::UncommonPlus => todo!(),
//             GameDataQuality::Count => todo!(),
//             GameDataQuality::Invalid => todo!(),
//         }
//     }
// }

mod with_structs {
    pub trait Category {
        fn category(&self) -> crate::interop::Category;
    }
    pub struct BonesMcCoy70V0;
    pub struct BonesMcCoy70V1;
    impl Category for BonesMcCoy70V0 {
        #[inline]
        fn category(&self) -> crate::interop::Category {
            crate::interop::Category::Healers
        }
    }
    impl Category for BonesMcCoy70V1 {
        #[inline]
        fn category(&self) -> crate::interop::Category {
            crate::interop::Category::Healers
        }
    }
    impl BonesMcCoy70V0 {
        #[inline]
        pub const fn substance_id(&self) -> crate::interop::SubstanceId {
            crate::interop::SubstanceId::new("Items.BonesMcCoy70V0")
        }
    }
    impl BonesMcCoy70V1 {
        #[inline]
        pub const fn substance_id(&self) -> crate::interop::SubstanceId {
            crate::interop::SubstanceId::new("Items.BonesMcCoy70V1")
        }
    }
    impl Category for crate::interop::SubstanceId {
        #[inline]
        fn category(&self) -> crate::interop::Category {
            match self {
                v if v == &BonesMcCoy70V0.substance_id() => BonesMcCoy70V0.category(),
                v if v == &BonesMcCoy70V1.substance_id() => BonesMcCoy70V1.category(),
                _ => todo!(),
            }
        }
    }
    pub const ALL: &[&dyn Category] = &[
        &BonesMcCoy70V0.substance_id(),
        &BonesMcCoy70V1,
        //...
    ];
}
mod with_consts {
    use crate::interop::SubstanceId;

    pub trait Category {
        fn category(&self) -> crate::interop::Category;
    }
    pub struct AnotherNameForSubstance<const TDBID: u64>;
    impl<const TDBID: u64> AnotherNameForSubstance<TDBID> {
        const SUBSTANCE_ID: crate::interop::SubstanceId =
            crate::interop::SubstanceId::new_from(TDBID);
    }
    impl<const TDBID: u64> Category for AnotherNameForSubstance<TDBID> {
        #[inline]
        fn category(&self) -> crate::interop::Category {
            match TDBID {
                1234u64 => crate::interop::Category::Healers,
                7891u64 => crate::interop::Category::Healers,
                _ => todo!()
            }
        }
    }
    impl<const TDBID: u64> AnotherNameForSubstance<TDBID> {
        #[inline]
        pub const fn substance_id(&self) -> crate::interop::SubstanceId {
            Self::SUBSTANCE_ID
        }
    }
    impl Category for crate::interop::SubstanceId {
        #[inline]
        fn category(&self) -> crate::interop::Category {
            match self.0.as_u64() {
                1234u64 => AnotherNameForSubstance::<1234u64>.category(),
                _ => todo!(),
            }
        }
    }
    pub const ALL: &[&dyn Category] = &[
        &AnotherNameForSubstance::<1234u64>::SUBSTANCE_ID,
        &AnotherNameForSubstance::<7891u64>,
        // ...
    ];
}
