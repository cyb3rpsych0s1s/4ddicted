//! alcohols
//!
//! - all alcohols are `ConsumableItem_Record`
//! - all alcohols can be identified through `ConsumableBaseName()` (`ConsumableBaseName.Alcohol`)
//! - all alcohols triggers `Consume` (`ObjectAction_Record`)

use red4ext_rs::types::{ItemId, TweakDbId};

use crate::{interop::ContainsItem, reference};

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

reference!(name: ALCOHOL, substance: Alcohol, kind: Hard, category: Alcohol, effect: "BaseStatusEffect.Drunk",
    [
        key: "Items.TopQualityAlcohol1", quality: Common,
        key: "Items.TopQualityAlcohol5", quality: Common,
        key: "Items.MediumQualityAlcohol1", quality: Common,
        key: "Items.TopQualityAlcohol9", quality: Common,
        key: "Items.MediumQualityAlcohol5", quality: Common,
        key: "Items.GoodQualityAlcohol1", quality: Common,
        key: "Items.GoodQualityAlcohol5", quality: Common,
        key: "Items.LowQualityAlcohol3", quality: Common,
        key: "Items.NomadsAlcohol1", quality: Common,
        key: "Items.LowQualityAlcohol7", quality: Common,
        key: "Items.TopQualityAlcohol", quality: Common,
        key: "Items.GoodQualityAlcohol", quality: Common,
        key: "Items.LowQualityAlcohol", quality: Common,
        key: "Items.LowQualityAlcohol6", quality: Common,
        key: "Items.LowQualityAlcohol2", quality: Common,
        key: "Items.GoodQualityAlcohol4", quality: Common,
        key: "Items.TopQualityAlcohol4", quality: Common,
        key: "Items.MediumQualityAlcohol4", quality: Common,
        key: "Items.TopQualityAlcohol8", quality: Common,
        key: "Items.MediumQualityAlcohol", quality: Common,
        key: "Items.GoodQualityAlcohol2", quality: Common,
        key: "Items.GoodQualityAlcohol6", quality: Common,
        key: "Items.MediumQualityAlcohol2", quality: Common,
        key: "Items.MediumQualityAlcohol6", quality: Common,
        key: "Items.TopQualityAlcohol2", quality: Common,
        key: "Items.TopQualityAlcohol6", quality: Common,
        key: "Items.NomadsAlcohol2", quality: Common,
        key: "Items.LowQualityAlcohol4", quality: Common,
        key: "Items.LowQualityAlcohol8", quality: Common,
        key: "Items.LowQualityAlcohol5", quality: Common,
        key: "Items.LowQualityAlcohol1", quality: Common,
        key: "Items.LowQualityAlcohol9", quality: Common,
        key: "Items.MediumQualityAlcohol7", quality: Common,
        key: "Items.MediumQualityAlcohol3", quality: Common,
        key: "Items.TopQualityAlcohol10", quality: Common,
        key: "Items.TopQualityAlcohol7", quality: Common,
        key: "Items.TopQualityAlcohol3", quality: Common,
        key: "Items.Alcohol", quality: Common,
        key: "Items.GoodQualityAlcohol3", quality: Common,
    ]
);
