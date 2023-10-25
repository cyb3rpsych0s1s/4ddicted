//! addictive consumables
//!
//! Addictive consumables can be identified different ways.
//!
//! All are processed through `ItemActionsHelper.ProcessItemAction(...)`.

mod healer;

pub use healer::*;
mod booster;
pub use booster::*;
mod neuro;
pub use neuro::*;
mod alcohol;
pub use alcohol::*;

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::interop::{ContainsItem, SubstanceId};

/// indicates whether something can be considered as addictive or not.
pub trait Addictive {
    fn addictive(&self) -> bool;
}

impl Addictive for ItemId {
    fn addictive(&self) -> bool {
        self.get_tdbid().addictive()
    }
}

impl Addictive for TweakDbId {
    fn addictive(&self) -> bool {
        self.is_healer() || self.is_booster() || self.is_neuro() || self.is_alcoholic() || todo!()
    }
}

impl Addictive for SubstanceId {
    fn addictive(&self) -> bool {
        true
    }
}

pub struct WeakenedEffectIds {
    pub notably_id: crate::interop::EffectId,
    pub severely_id: crate::interop::EffectId,
}

pub struct Effect {
    pub id: crate::interop::EffectId,
    pub weakened_ids: Option<WeakenedEffectIds>,
}

pub struct SubstanceDetails {
    pub substance: crate::interop::Substance,
    pub kind: crate::interop::Kind,
    pub quality: cp2077_rs::GameDataQuality,
    pub category: crate::interop::Category,
    pub effect: Effect,
}

impl ContainsItem for std::collections::HashMap<SubstanceId, SubstanceDetails> {
    fn contains_id(&self, value: &TweakDbId) -> bool {
        self.keys().any(|x| x.0.eq(value))
    }
}

#[macro_export]
macro_rules! reference {
    (name: $name:ident, substance: $substance:ident, kind: $kind:ident, category: $category:ident, [$(key: $key:literal, quality: $quality:ident, effect: ($effect_id:literal $(, $notably_weakened_effect_id:expr, $severely_weakened_effect_id:expr)?)),+ $(,)?]) => {
        reference!(name: $name, [$(key: $key, substance: $substance, kind: $kind, quality: $quality, category: $category, effect: ($effect_id)),+]);
    };
    (name: $name:ident, substance: $substance:ident, kind: $kind:ident, category: $category:ident, effect:$effect_id:literal, [$(key: $key:literal, quality: $quality:ident),+ $(,)?]) => {
        reference!(name: $name, [$(key: $key, substance: $substance, kind: $kind, quality: $quality, category: $category, effect: ($effect_id)),+]);
    };
    (name: $name:ident, effect:$effect_id:literal, [$(key: $key:literal, substance: $substance:ident, kind: $kind:ident, quality: $quality:ident, category: $category:ident),+ $(,)?]) => {
        reference!(name: $name, [$(key: $key, substance: $substance, kind: $kind, quality: $quality, category: $category, effect: ($effect_id)),+]);
    };
    (name: $name:ident, [$(key: $key:literal, substance: $substance:ident, kind: $kind:ident, quality: $quality:ident, category: $category:ident, effect: ($effect_id:literal $(, $notably_weakened_effect_id:expr, $severely_weakened_effect_id:expr)?)),+ $(,)?]) => {
        ::lazy_static::lazy_static!(
            pub static ref $name: ::std::collections::HashMap<$crate::interop::SubstanceId, $crate::addictive::SubstanceDetails> = {
                let mut map = ::std::collections::HashMap::new();
                $(
                    #[allow(unused_mut)]
                    let mut effect: $crate::addictive::Effect = $crate::addictive::Effect {
                        id: $crate::interop::EffectId::new($effect_id),
                        weakened_ids: None,
                    };
                    $(
                        effect.weakened_ids = Some($crate::addictive::WeakenedEffectIds { notably_id: $notably_weakened_effect_id, severely_id: $severely_weakened_effect_id });
                    )?
                    map.insert(crate::interop::SubstanceId::new($key), crate::addictive::SubstanceDetails {
                        substance: crate::interop::Substance::$substance,
                        kind: crate::interop::Kind::$kind,
                        quality: ::cp2077_rs::GameDataQuality::$quality,
                        category: crate::interop::Category::$category,
                        effect,
                    });
                )+
                map
            };
        );
    };
}
