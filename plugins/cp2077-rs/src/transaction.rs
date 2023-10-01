use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, ItemId, Ref},
};

use crate::{GameItemData, GameObject};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct TransactionSystem(Ref<IScriptable>);

unsafe impl RefRepr for TransactionSystem {
    const CLASS_NAME: &'static str = "gameTransactionSystem";

    type Type = Strong;
}

#[redscript_import]
impl TransactionSystem {
    /// `public final native func GetItemData(obj: ref<GameObject>, itemID: ItemID) -> wref<gameItemData>`
    #[redscript(native)]
    pub fn get_item_data(&self, obj: GameObject, item: ItemId) -> GameItemData;
}
