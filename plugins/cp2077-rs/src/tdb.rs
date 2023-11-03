use red4ext_rs::{
    prelude::{redscript_import, ClassType, NativeRepr},
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

#[derive(Debug)]
pub struct StatRecord;

impl ClassType for StatRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataStat_Record";
}

#[redscript_import]
impl StatRecord {
    /// `public native EnumName(): CName`
    #[redscript(native)]
    pub fn enum_name(self: &Ref<Self>) -> CName;
    /// `public native StatType(): gamedataStatType`
    pub fn stat_type(self: &Ref<Self>) -> StatType;
}

#[derive(Debug)]
pub struct StatPoolRecord;

impl ClassType for StatPoolRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataStatPool_Record";
}

#[redscript_import]
impl StatPoolRecord {
    /// `public native EnumName(): CName`
    #[redscript(native)]
    pub fn enum_name(self: &Ref<Self>) -> CName;
    /// `public native Stat(): Stat_Record`
    pub fn stat(self: &Ref<Self>) -> Ref<StatRecord>;
}

#[cfg(feature = "codeware")]
pub fn stat_records_eq(one: &Ref<StatRecord>, another: &Ref<StatRecord>) -> bool {
    let stat_pool_type = crate::Reflection::get_enum(CName::new(StatType::NATIVE_NAME))
        .into_ref()
        .unwrap();
    let variants = stat_pool_type.get_constants();
    let mut invalid: i64 = -1;
    for variant in variants {
        if variant.get_name() == CName::new("Invalid") {
            invalid = variant.get_value();
            break;
        }
    }
    if invalid == -1 {
        panic!("gamedataStatPoolType.Invalid couldn't be retrieved from Reflection");
    }
    match (one, another) {
        (x, y) if x.stat_type() == invalid && y.stat_type() == invalid => {
            x.enum_name().eq(&y.enum_name())
        }
        (x, y) => x.stat_type().eq(&y.stat_type()),
    }
}

#[derive(Debug)]
pub struct StatPoolUpdateRecord;

impl ClassType for StatPoolUpdateRecord {
    type BaseClass = TweakDbRecord;
    const NAME: &'static str = "gamedataStatPoolUpdate_Record";
}

#[redscript_import]
impl StatPoolUpdateRecord {
    /// `public native StatPoolType(): StatPool_Record`
    #[redscript(native)]
    pub fn stat_pool_type(self: &Ref<Self>) -> Ref<StatPoolRecord>;
}

#[derive(Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
#[allow(dead_code)]
struct StatType(i64);

impl PartialEq<i64> for StatType {
    fn eq(&self, other: &i64) -> bool {
        self.0.eq(other)
    }
}
impl PartialEq<StatType> for i64 {
    fn eq(&self, other: &StatType) -> bool {
        self.eq(&other.0)
    }
}

unsafe impl NativeRepr for StatType {
    const NAME: &'static str = "gamedataStatType";
}
