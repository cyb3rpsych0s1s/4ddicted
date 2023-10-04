use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, ItemId, Ref},
};

use crate::{GameInstance, GameItemData, GameObject};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct RPGManager(Ref<IScriptable>);

unsafe impl RefRepr for RPGManager {
    const CLASS_NAME: &'static str = "gameRPGManager";
    type Type = Strong;
}

#[redscript_import]
impl RPGManager {
    /// `public final static native func GetItemData(gi: GameInstance, owner: ref<GameObject>, itemID: ItemID) -> wref<gameItemData>;`
    #[redscript(native)]
    pub fn get_item_data(gi: GameInstance, owner: GameObject, item: ItemId) -> GameItemData;
}
