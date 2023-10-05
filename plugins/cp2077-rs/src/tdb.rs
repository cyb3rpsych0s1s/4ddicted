use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong, Weak},
    types::{IScriptable, Ref, TweakDbId, WRef},
};

use crate::{GameDataEquipmentArea, IsDefined};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct TweakDBInterface(Ref<IScriptable>);

unsafe impl RefRepr for TweakDBInterface {
    const CLASS_NAME: &'static str = "gamedataTweakDBInterface";
    type Type = Strong;
}

#[redscript_import]
impl TweakDBInterface {
    /// `public static native GetItemRecord(path: TweakDBID): Item_Record`
    #[redscript(native)]
    pub fn get_item_record(path: TweakDbId) -> ItemRecord;
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ItemRecord(Ref<IScriptable>);

unsafe impl RefRepr for ItemRecord {
    const CLASS_NAME: &'static str = "gamedataItem_Record";
    type Type = Strong;
}

#[redscript_import]
impl ItemRecord {
    // `public final native func EquipArea() -> wref<EquipmentArea_Record>`
    #[redscript(native)]
    pub fn equip_area(&self) -> EquipmentAreaRecord;
}

impl IsDefined for ItemRecord {
    fn is_defined(&self) -> bool {
        !self.0.clone().into_shared().as_ptr().is_null()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct EquipmentAreaRecord(WRef<IScriptable>);

unsafe impl RefRepr for EquipmentAreaRecord {
    const CLASS_NAME: &'static str = "gamedataEquipmentArea_Record";
    type Type = Weak;
}

impl IsDefined for EquipmentAreaRecord {
    fn is_defined(&self) -> bool {
        !self.0.clone().into_shared().as_ptr().is_null()
    }
}

#[redscript_import]
impl EquipmentAreaRecord {
    /// `public final native func GetID() -> TweakDBID`
    #[redscript(native)]
    pub fn get_id(&self) -> TweakDbId;
    /// `public final native func Type() -> gamedataEquipmentArea`
    #[redscript(native)]
    pub fn r#type(&self) -> GameDataEquipmentArea;
}
