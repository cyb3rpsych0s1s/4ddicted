use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, Ref, TweakDbId, WRef},
};

use crate::GameDataEquipmentArea;

#[derive(Debug)]
pub struct TweakDBInterface;

impl ClassType for TweakDBInterface {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataTweakDBInterface";
}

#[derive(Debug)]
pub struct ItemRecord;

impl ClassType for ItemRecord {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataItem_Record";
}

#[redscript_import]
impl ItemRecord {
    // `public final native func EquipArea() -> wref<EquipmentArea_Record>`
    #[redscript(native)]
    pub fn equip_area(self: &Ref<Self>) -> WRef<EquipmentAreaRecord>;
}

#[derive(Debug)]
pub struct EquipmentAreaRecord;

impl ClassType for EquipmentAreaRecord {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataEquipmentArea_Record";
}

#[redscript_import]
impl EquipmentAreaRecord {
    /// `public final native func GetID() -> TweakDBID`
    #[redscript(native)]
    pub fn get_id(self: &Ref<Self>) -> TweakDbId;
    /// `public final native func Type() -> gamedataEquipmentArea`
    #[redscript(native)]
    pub fn r#type(self: &Ref<Self>) -> GameDataEquipmentArea;
}
