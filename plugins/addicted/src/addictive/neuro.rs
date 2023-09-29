use red4ext_rs::types::{ItemId, TweakDbId};

pub const BLACK_LACE: [TweakDbId; 2] = [
    TweakDbId::new("Items.BlackLaceV0"),
    TweakDbId::new("Items.BlackLaceV1"),
];

pub trait Neuro {
    fn is_neuro(&self) -> bool {
        todo!()
    }
    fn is_blacklace(&self) -> bool;
}

impl Neuro for ItemId {
    fn is_blacklace(&self) -> bool {
        BLACK_LACE.contains(&self.get_tdbid())
    }
}
