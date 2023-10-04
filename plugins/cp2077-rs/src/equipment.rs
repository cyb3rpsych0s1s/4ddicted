use red4ext_rs::{
    prelude::{redscript_import, NativeRepr, RefRepr, Strong},
    types::{CName, IScriptable, ItemId, Ref, TweakDbId},
};

use crate::ScriptedPuppet;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct EquipmentSystem(Ref<IScriptable>);

unsafe impl RefRepr for EquipmentSystem {
    const CLASS_NAME: &'static str = "gameIEquipmentSystem";
    type Type = Strong;
}

#[redscript_import]
impl EquipmentSystem {
    /// `public final static func GetEquipAreaType(item: ItemID) -> gamedataEquipmentArea`
    pub fn get_equip_area_type(item: ItemId) -> GameDataEquipmentArea;
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct InventoryDataManagerV2(Ref<IScriptable>);

unsafe impl RefRepr for InventoryDataManagerV2 {
    const CLASS_NAME: &'static str = "InventoryDataManagerV2";
    type Type = Strong;
}

#[redscript_import]
impl InventoryDataManagerV2 {}

impl InventoryDataManagerV2 {
    /// see [IsEquipmentAreaCyberware](https://codeberg.org/adamsmasher/cyberpunk/src/commit/20e2051921152b83f1daa57ecadf7f3b3288cf8e/cyberpunk/UI/inventory/inventoryDataManagerV2.swift#L3765)
    pub fn is_equipment_area_cyberware(area_type: GameDataEquipmentArea) -> bool {
        match area_type {
            GameDataEquipmentArea::AbilityCW
            | GameDataEquipmentArea::NervousSystemCW
            | GameDataEquipmentArea::MusculoskeletalSystemCW
            | GameDataEquipmentArea::IntegumentarySystemCW
            | GameDataEquipmentArea::ImmuneSystemCW
            | GameDataEquipmentArea::LegsCW
            | GameDataEquipmentArea::EyesCW
            | GameDataEquipmentArea::CardiovascularSystemCW
            | GameDataEquipmentArea::HandsCW
            | GameDataEquipmentArea::ArmsCW
            | GameDataEquipmentArea::SystemReplacementCW => true,
            _ => false,
        }
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct EquipmentSystemPlayerData(Ref<IScriptable>);

unsafe impl RefRepr for EquipmentSystemPlayerData {
    const CLASS_NAME: &'static str = "EquipmentSystemPlayerData";
    type Type = Strong;
}

#[redscript_import]
impl EquipmentSystemPlayerData {
    /// `public final const func GetPaperDollEquipAreas() -> array<SEquipArea>`
    pub fn get_paper_doll_equip_areas(&self) -> Vec<SEquipArea>;
    /// `private final const func GetItemInEquipSlot(equipAreaIndex: Int32, slotIndex: Int32) -> ItemID`
    pub fn get_item_in_equip_slot(&self, equip_area_index: i32, slot_index: i32) -> ItemId;
    /// `public final func GetOwner() -> wref<ScriptedPuppet>`
    pub fn get_owner(&self) -> ScriptedPuppet;
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SLoadout {
    equip_areas: Vec<SEquipArea>,
    equipment_sets: Vec<SEquipmentSet>,
}

unsafe impl NativeRepr for SLoadout {
    const NAME: &'static str = "SLoadout";
    const NATIVE_NAME: &'static str = "gameSLoadout";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SEquipArea {
    area_type: GameDataEquipmentArea,
    equip_slots: Vec<SEquipSlot>,
    active_index: i32,
}

unsafe impl NativeRepr for SEquipArea {
    const NAME: &'static str = "SEquipArea";
    const NATIVE_NAME: &'static str = "gameSEquipArea";
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(i64)]
#[non_exhaustive]
#[allow(dead_code)]
pub enum GameDataEquipmentArea {
    #[default]
    AbilityCW = 0,
    ArmsCW = 1,
    BaseFists = 2,
    BotCPU = 3,
    BotChassisModule = 4,
    BotMainModule = 5,
    BotSoftware = 6,
    CardiovascularSystemCW = 7,
    Consumable = 8,
    CyberwareWheel = 9,
    EyesCW = 10,
    Face = 11,
    FaceCW = 12,
    Feet = 13,
    FrontalCortexCW = 14,
    Gadget = 15,
    HandsCW = 16,
    Head = 17,
    ImmuneSystemCW = 18,
    InnerChest = 19,
    IntegumentarySystemCW = 20,
    LeftArm = 21,
    Legs = 22,
    LegsCW = 23,
    MusculoskeletalSystemCW = 24,
    NervousSystemCW = 25,
    OuterChest = 26,
    Outfit = 27,
    PersonalLink = 28,
    PlayerTattoo = 29,
    Quest = 30,
    QuickSlot = 31,
    QuickWheel = 32,
    RightArm = 33,
    SilverhandArm = 34,
    Splinter = 35,
    SystemReplacementCW = 36,
    UnderwearBottom = 37,
    UnderwearTop = 38,
    VDefaultHandgun = 39,
    Weapon = 40,
    WeaponHeavy = 41,
    WeaponLeft = 42,
    WeaponWheel = 43,
    Count = 44,
    Invalid = 45,
}

unsafe impl NativeRepr for GameDataEquipmentArea {
    const NAME: &'static str = "gamedataEquipmentArea";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SEquipSlot {
    item_id: ItemId,
    slot_id: TweakDbId,
    unlock_prereq: IPrereq,
    visible_when_locked: bool,
}

unsafe impl NativeRepr for SEquipSlot {
    const NAME: &'static str = "SEquipSlot";
    const NATIVE_NAME: &'static str = "gameSEquipSlot";
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct IPrereq(Ref<IScriptable>);

unsafe impl RefRepr for IPrereq {
    const CLASS_NAME: &'static str = "gameIPrereq";
    type Type = Strong;
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SEquipmentSet {
    set_items: Vec<SItemInfo>,
    set_name: CName,
    set_type: EEquipmentSetType,
}

unsafe impl NativeRepr for SEquipmentSet {
    const NAME: &'static str = "SEquipmentSet";
    const NATIVE_NAME: &'static str = "gameSEquipmentSet";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SItemInfo {
    item_id: ItemId,
    slot_index: i32,
}

unsafe impl NativeRepr for SItemInfo {
    const NAME: &'static str = "SItemInfo";
    const NATIVE_NAME: &'static str = "gameSItemInfo";
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(i64)]
#[non_exhaustive]
#[allow(dead_code)]
pub enum EEquipmentSetType {
    #[default]
    Offensive = 0,
    Defensive = 1,
    Cyberware = 2,
}

unsafe impl NativeRepr for EEquipmentSetType {
    const NAME: &'static str = "EEquipmentSetType";
    const NATIVE_NAME: &'static str = "EquipmentSetType";
}
