pub trait Category {
    fn category(&self) -> crate::interop::Category;
}
pub trait Quality {
    fn quality(&self) -> cp2077_rs::GameDataQuality;
}
macro_rules! count_tts {
    () => { 0 };
    ($odd:tt $($a:tt $b:tt)*) => { (count_tts!($($a)*) << 1) | 1 };
    ($($a:tt $even:tt)*) => { count_tts!($($a)*) << 1 };
}
macro_rules! substance {
    ($id: ident, $category: expr, $quality: expr) => {
        substance!($id, $category, $quality, $id);
    };
    ($id: ident, $category: expr, $quality: expr, $effect: ident) => {
        pub struct $id;
        impl $id {
            const SUBSTANCE_ID: crate::interop::SubstanceId =
                crate::interop::SubstanceId::new(::const_str::concat!("Items.", stringify!($id)));
            const EFFECT_ID: crate::interop::EffectId = crate::interop::EffectId::new(
                ::const_str::concat!("BaseStatusEffect.", stringify!($effect)),
            );
        }
        impl Category for $id {
            #[inline]
            fn category(&self) -> crate::interop::Category {
                $category
            }
        }
        impl Quality for $id {
            #[inline]
            fn quality(&self) -> ::cp2077_rs::GameDataQuality {
                $quality
            }
        }
    };
}
macro_rules! healers {
    ($({ $id: ident, $quality: expr $(, $effect: ident)? }),+ $(,)?) => {
        $(substance!($id, crate::interop::Category::Healers, $quality $(, $effect)?);)+
        pub const HEALER: [crate::interop::SubstanceId; count_tts!($($id)+)] = [
            $($id::SUBSTANCE_ID),+
        ];
    };
}
macro_rules! alcohols {
    ($({ $id: ident, $quality: expr $(, $effect: ident)? }),+ $(,)?) => {
        $(substance!($id, crate::interop::Category::Alcohol, $quality $(, $effect)?);)+
        pub const ALCOHOL: [crate::interop::SubstanceId; count_tts!($($id)+)] = [
            $($id::SUBSTANCE_ID),+
        ];
    };
}

healers!(
    { FirstAidWhiffV0, ::cp2077_rs::GameDataQuality::Common },
    { FirstAidWhiffV1, ::cp2077_rs::GameDataQuality::Rare },
    { FirstAidWhiffVCommonPlus, ::cp2077_rs::GameDataQuality::Rare, FirstAidWhiffV0 },
);
alcohols!(
    { TopQualityAlcohol1, ::cp2077_rs::GameDataQuality::Common },
);
