use red4ext_rs::{
    info,
    prelude::{redscript_import, NativeRepr, RefRepr, Strong},
    types::{CName, IScriptable, ItemId, RedArray, Ref, TweakDbId},
};

use crate::{GameObject, ScriptedPuppet, TweakDBInterface, IsDefined};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct EquipmentSystem(Ref<IScriptable>);

unsafe impl RefRepr for EquipmentSystem {
    const CLASS_NAME: &'static str = "gameIEquipmentSystem";
    type Type = Strong;
}

#[redscript_import]
impl EquipmentSystem {
    /// `public final static func GetInstance(owner: ref<GameObject>) -> ref<EquipmentSystem>`
    pub fn get_instance(owner: GameObject) -> EquipmentSystem;
    // /// `public final static func GetEquipAreaType(item: ItemID) -> gamedataEquipmentArea`
    // #[redscript(name = "GetEquipAreaType")]
    // fn inner_get_equip_area_type(item: ItemId) -> GameDataEquipmentArea;
}

impl EquipmentSystem {
    /// see [GetEquipAreaType](https://codeberg.org/adamsmasher/cyberpunk/src/commit/20e2051921152b83f1daa57ecadf7f3b3288cf8e/cyberpunk/systems/equipmentSystem.swift#L4229)
    pub fn get_equip_area_type(&self, item: ItemId) -> GameDataEquipmentArea {
        let item = TweakDBInterface::get_item_record(item.get_tdbid());
        if item.is_defined() {
            let area = item.equip_area();
            if area.is_defined() && area.get_id() != TweakDbId::default() {
                return area.r#type();
            }
        }
        GameDataEquipmentArea::Invalid
    }
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
    fn get_item_in_equip_slot(&self, equip_area_index: i32, slot_index: i32) -> ItemId;
    /// `public final func GetOwner() -> wref<ScriptedPuppet>`
    pub fn get_owner(&self) -> ScriptedPuppet;
    /// # Safety
    ///
    /// on game launch, the method can be called but is uninitialized,
    /// which can cause UB.
    ///
    /// `public GetEquipment(): SLoadout`
    #[redscript(name = "GetEquipment")]
    pub unsafe fn get_equipment_unchecked(&self) -> SLoadout;
    /*
    Vec
    Error reason: Unhandled exception
    Expression: EXCEPTION_ACCESS_VIOLATION (0xC0000005)
    Message: The thread attempted to read inaccessible data at 0x20.
    File: <Unknown>(0)

    RedArray
    Error reason: Unhandled exception
    Expression: EXCEPTION_ACCESS_VIOLATION (0xC0000005)
    Message: The thread attempted to read inaccessible data at 0x0.
    File: <Unknown>(0)
    */
}

#[cfg(feature = "codeware")]
impl EquipmentSystemPlayerData {
    pub fn get_item(&self, equip_area_index: i32, slot_index: i32) -> Option<ItemId> {
        info!("about to load loadout");
        let loadout = unsafe { self.get_equipment_unchecked() };
        info!("got loadout");
        if let Some(area) = loadout
            .equip_areas
            .as_slice()
            .get(equip_area_index as usize)
        {
            info!("got area");
            if let Some(slot) = area.equip_slots.as_slice().get(slot_index as usize) {
                info!("got slot");
                return Some(slot.item_id);
            }
        }
        None
    }
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SLoadout {
    equip_areas: RedArray<SEquipArea>,
    equipment_sets: RedArray<SEquipmentSet>,
}

unsafe impl NativeRepr for SLoadout {
    const NAME: &'static str = "gameSLoadout";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct SEquipArea {
    area_type: GameDataEquipmentArea,
    equip_slots: RedArray<SEquipSlot>,
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
    set_items: RedArray<SItemInfo>,
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
