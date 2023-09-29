//! alcohols
//!
//! - all alcohols are `ConsumableItem_Record`
//! - all alcohols can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Alcohol`)
//! - all alcohols triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

pub trait Alcoholic {
    fn is_alcoholic(&self) -> bool;
}

impl Alcoholic for ItemId {
    fn is_alcoholic(&self) -> bool {
        ALCOHOL.contains(&self.get_tdbid())
    }
}

pub const ALCOHOL: [TweakDbId; 39] = [
    TweakDbId::new("Items.TopQualityAlcohol1"),
    TweakDbId::new("Items.TopQualityAlcohol5"),
    TweakDbId::new("Items.MediumQualityAlcohol1"),
    TweakDbId::new("Items.TopQualityAlcohol9"),
    TweakDbId::new("Items.MediumQualityAlcohol5"),
    TweakDbId::new("Items.GoodQualityAlcohol1"),
    TweakDbId::new("Items.GoodQualityAlcohol5"),
    TweakDbId::new("Items.LowQualityAlcohol3"),
    TweakDbId::new("Items.NomadsAlcohol1"),
    TweakDbId::new("Items.LowQualityAlcohol7"),
    TweakDbId::new("Items.TopQualityAlcohol"),
    TweakDbId::new("Items.GoodQualityAlcohol"),
    TweakDbId::new("Items.LowQualityAlcohol"),
    TweakDbId::new("Items.LowQualityAlcohol6"),
    TweakDbId::new("Items.LowQualityAlcohol2"),
    TweakDbId::new("Items.GoodQualityAlcohol4"),
    TweakDbId::new("Items.TopQualityAlcohol4"),
    TweakDbId::new("Items.MediumQualityAlcohol4"),
    TweakDbId::new("Items.TopQualityAlcohol8"),
    TweakDbId::new("Items.MediumQualityAlcohol"),
    TweakDbId::new("Items.GoodQualityAlcohol2"),
    TweakDbId::new("Items.GoodQualityAlcohol6"),
    TweakDbId::new("Items.MediumQualityAlcohol2"),
    TweakDbId::new("Items.MediumQualityAlcohol6"),
    TweakDbId::new("Items.TopQualityAlcohol2"),
    TweakDbId::new("Items.TopQualityAlcohol6"),
    TweakDbId::new("Items.NomadsAlcohol2"),
    TweakDbId::new("Items.LowQualityAlcohol4"),
    TweakDbId::new("Items.LowQualityAlcohol8"),
    TweakDbId::new("Items.LowQualityAlcohol5"),
    TweakDbId::new("Items.LowQualityAlcohol1"),
    TweakDbId::new("Items.LowQualityAlcohol9"),
    TweakDbId::new("Items.MediumQualityAlcohol7"),
    TweakDbId::new("Items.MediumQualityAlcohol3"),
    TweakDbId::new("Items.TopQualityAlcohol10"),
    TweakDbId::new("Items.TopQualityAlcohol7"),
    TweakDbId::new("Items.TopQualityAlcohol3"),
    TweakDbId::new("Items.Alcohol"),
    TweakDbId::new("Items.GoodQualityAlcohol3"),
];
