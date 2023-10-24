use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{CName, IScriptable, Ref, TweakDbId, WRef},
};

use crate::GameDataEquipmentArea;

#[derive(Debug)]
pub struct TweakDbInterface;

impl ClassType for TweakDbInterface {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataTweakDBInterface";
}

#[redscript_import]
impl TweakDbInterface {
    /// public final static native func GetObjectActionEffectRecord(path: TweakDBID) -> ref<ObjectActionEffect_Record>
    #[redscript(native)]
    pub fn get_object_action_effect_record(path: TweakDbId) -> Ref<ObjectActionEffectRecord>;
    /// `public static native func GetStatusEffectUIDataRecord(path: TweakDBID) -> ref<StatusEffectUIData_Record>`
    #[redscript(native)]
    pub fn get_status_effect_ui_data_record(path: TweakDbId) -> Ref<StatusEffectUIDataRecord>;
}

#[cfg(feature = "tweakxl")]
#[redscript_import]
impl TweakDbInterface {
    /// `public final static native func GetRecords(type: CName) -> array<ref<TweakDBRecord>>`
    #[redscript(native)]
    pub fn get_records(r#type: CName) -> Vec<Ref<TweakDbRecord>>;
}

#[derive(Debug)]
pub struct TweakDbRecord;

impl ClassType for TweakDbRecord {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataTweakDBRecord";
}

#[redscript_import]
impl TweakDbRecord {
    /// `public final native func GetID() -> TweakDBID`
    #[redscript(native, name = "GetID")]
    pub fn get_id(self: &Ref<Self>) -> TweakDbId;
    /// `public final native func GetRecordID() -> TweakDBID`
    #[redscript(native, name = "GetRecordID")]
    pub fn get_record_id(self: &Ref<Self>) -> TweakDbId;
}

#[derive(Debug)]
pub struct ItemRecord;

impl ClassType for ItemRecord {
    type BaseClass = TweakDbRecord;
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
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataEquipmentArea_Record";
}

#[redscript_import]
impl EquipmentAreaRecord {
    /// `public final native func Type() -> gamedataEquipmentArea`
    #[redscript(native)]
    pub fn r#type(self: &Ref<Self>) -> GameDataEquipmentArea;
}

impl EquipmentAreaRecord {
    pub fn get_id(self: &Ref<Self>) -> TweakDbId {
        red4ext_rs::prelude::Ref::<EquipmentAreaRecord>::upcast(self.clone()).get_id()
    }
}

#[derive(Debug)]
pub struct StatusEffectRecord;

impl ClassType for StatusEffectRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataStatusEffect_Record";
}

impl StatusEffectRecord {
    pub fn get_id(self: &Ref<Self>) -> TweakDbId {
        red4ext_rs::prelude::Ref::<StatusEffectRecord>::upcast(self.clone()).get_id()
    }
}

#[derive(Debug)]
pub struct ObjectActionEffectRecord;

impl ClassType for ObjectActionEffectRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataObjectActionEffect_Record";
}

#[redscript_import]
impl ObjectActionEffectRecord {
    /// `public final native func StatusEffect() -> wref<StatusEffect_Record>`
    #[redscript(native)]
    pub fn status_effect(self: &Ref<Self>) -> WRef<StatusEffectRecord>;
}

impl ObjectActionEffectRecord {
    pub fn get_id(self: &Ref<Self>) -> TweakDbId {
        red4ext_rs::prelude::Ref::<ObjectActionEffectRecord>::upcast(self.clone()).get_id()
    }
}

#[derive(Debug)]
pub struct StatusEffectUIDataRecord;

impl ClassType for StatusEffectUIDataRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataStatusEffectUIData_Record";
}

#[derive(Debug)]
pub struct UIIconRecord;

impl ClassType for UIIconRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataUIIcon_Record";
}
