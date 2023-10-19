//! alcohols
//!
//! - all alcohols are `ConsumableItem_Record`
//! - all alcohols can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Alcohol`)
//! - all alcohols triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::interop::{ContainsItem, SubstanceId};

pub trait Alcoholic {
    fn is_alcoholic(&self) -> bool;
}

impl Alcoholic for ItemId {
    fn is_alcoholic(&self) -> bool {
        ALCOHOL.contains_item(self)
    }
}

impl Alcoholic for TweakDbId {
    fn is_alcoholic(&self) -> bool {
        ALCOHOL.contains_id(self)
    }
}

pub const ALCOHOL: [SubstanceId; 39] = [
    SubstanceId::new("Items.TopQualityAlcohol1"),
    SubstanceId::new("Items.TopQualityAlcohol5"),
    SubstanceId::new("Items.MediumQualityAlcohol1"),
    SubstanceId::new("Items.TopQualityAlcohol9"),
    SubstanceId::new("Items.MediumQualityAlcohol5"),
    SubstanceId::new("Items.GoodQualityAlcohol1"),
    SubstanceId::new("Items.GoodQualityAlcohol5"),
    SubstanceId::new("Items.LowQualityAlcohol3"),
    SubstanceId::new("Items.NomadsAlcohol1"),
    SubstanceId::new("Items.LowQualityAlcohol7"),
    SubstanceId::new("Items.TopQualityAlcohol"),
    SubstanceId::new("Items.GoodQualityAlcohol"),
    SubstanceId::new("Items.LowQualityAlcohol"),
    SubstanceId::new("Items.LowQualityAlcohol6"),
    SubstanceId::new("Items.LowQualityAlcohol2"),
    SubstanceId::new("Items.GoodQualityAlcohol4"),
    SubstanceId::new("Items.TopQualityAlcohol4"),
    SubstanceId::new("Items.MediumQualityAlcohol4"),
    SubstanceId::new("Items.TopQualityAlcohol8"),
    SubstanceId::new("Items.MediumQualityAlcohol"),
    SubstanceId::new("Items.GoodQualityAlcohol2"),
    SubstanceId::new("Items.GoodQualityAlcohol6"),
    SubstanceId::new("Items.MediumQualityAlcohol2"),
    SubstanceId::new("Items.MediumQualityAlcohol6"),
    SubstanceId::new("Items.TopQualityAlcohol2"),
    SubstanceId::new("Items.TopQualityAlcohol6"),
    SubstanceId::new("Items.NomadsAlcohol2"),
    SubstanceId::new("Items.LowQualityAlcohol4"),
    SubstanceId::new("Items.LowQualityAlcohol8"),
    SubstanceId::new("Items.LowQualityAlcohol5"),
    SubstanceId::new("Items.LowQualityAlcohol1"),
    SubstanceId::new("Items.LowQualityAlcohol9"),
    SubstanceId::new("Items.MediumQualityAlcohol7"),
    SubstanceId::new("Items.MediumQualityAlcohol3"),
    SubstanceId::new("Items.TopQualityAlcohol10"),
    SubstanceId::new("Items.TopQualityAlcohol7"),
    SubstanceId::new("Items.TopQualityAlcohol3"),
    SubstanceId::new("Items.Alcohol"),
    SubstanceId::new("Items.GoodQualityAlcohol3"),
];
