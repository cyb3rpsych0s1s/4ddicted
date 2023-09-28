use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, ItemId, Ref, WRef},
};

use crate::{GameInstance, GameItemData, GameObject};

#[derive(Debug)]
pub struct RPGManager;

impl ClassType for RPGManager {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameRPGManager";
}

#[redscript_import]
impl RPGManager {
    /// `public final static native func GetItemData(gi: GameInstance, owner: ref<GameObject>, itemID: ItemID) -> wref<gameItemData>;`
    #[redscript(native)]
    pub fn get_item_data(
        gi: GameInstance,
        owner: Ref<GameObject>,
        item: ItemId,
    ) -> WRef<GameItemData>;
}
