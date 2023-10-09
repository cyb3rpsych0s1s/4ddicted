use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, ItemId, Ref, WRef},
};

use crate::{GameItemData, GameObject};

#[derive(Debug)]
pub struct TransactionSystem;

impl ClassType for TransactionSystem {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameTransactionSystem";
}

#[redscript_import]
impl TransactionSystem {
    /// `public final native func GetItemData(obj: ref<GameObject>, itemID: ItemID) -> wref<gameItemData>`
    #[redscript(native)]
    pub fn get_item_data(
        self: &Ref<Self>,
        obj: Ref<GameObject>,
        item: ItemId,
    ) -> WRef<GameItemData>;
}
