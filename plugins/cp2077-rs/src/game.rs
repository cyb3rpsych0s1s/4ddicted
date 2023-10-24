use std::ffi::c_void;

use red4ext_rs::{
    prelude::{redscript_import, ClassType, NativeRepr},
    types::{CName, IScriptable, Ref},
};

#[derive(Clone)]
#[repr(C)]
pub struct GameInstance {
    instance: *mut c_void,
    unk8: i8,
    unk10: i64,
}

impl Default for GameInstance {
    fn default() -> Self {
        Self {
            instance: std::ptr::null_mut(),
            unk8: 0,
            unk10: 0,
        }
    }
}

unsafe impl NativeRepr for GameInstance {
    const NAME: &'static str = "GameInstance";
    const NATIVE_NAME: &'static str = "ScriptGameInstance";
}

#[derive(Debug)]
pub struct ScriptableSystemsContainer;

impl ClassType for ScriptableSystemsContainer {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameScriptableSystemsContainer";
}

#[redscript_import]
impl ScriptableSystemsContainer {
    /// `public final native func Get(systemName: CName) -> ref<ScriptableSystem>;`
    #[redscript(native)]
    pub fn get(self: &Ref<Self>, system_name: CName) -> Ref<ScriptableSystem>;
}

#[derive(Debug)]
pub struct ScriptableSystem;

impl ClassType for ScriptableSystem {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameScriptableSystem";
}

#[derive(Debug)]
pub struct GameObject;

impl ClassType for GameObject {
    type BaseClass = IScriptable;
    const NAME: &'static str = "GameObject";
    /// required when `GameObject` expected in signature yet `whandle:gameObject` expected when performing `call!`
    const NATIVE_NAME: &'static str = "gameObject";
}

#[redscript_import]
impl GameObject {
    /// `public final native const func GetGame() -> GameInstance;`
    #[redscript(native)]
    pub fn get_game(self: &Ref<Self>) -> GameInstance;
}

#[derive(Debug)]
pub struct GameItemData;

impl ClassType for GameItemData {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameItemData";
}

#[redscript_import]
impl GameItemData {
    /// `public final native func GetStatValueByType(type: gamedataStatType) -> Float;`
    #[redscript(native)]
    fn get_stat_value_by_type(self: &Ref<Self>, r#type: GameDataStatType) -> f32;

    /// `public final native const func HasTag(tag: CName) -> Bool;`
    #[redscript(native)]
    pub fn has_tag(self: &Ref<Self>, tag: CName) -> bool;
}

impl GameItemData {
    /// see RPGManager
    ///
    /// `public final static func GetItemQuality(qualityStat: Float) -> gamedataQuality`
    pub fn get_quality(self: &Ref<Self>) -> GameDataQuality {
        let stat = self
            .get_stat_value_by_type(GameDataStatType::Quality)
            .round() as u32;
        match stat {
            1 => GameDataQuality::Uncommon,
            2 => GameDataQuality::Rare,
            3 => GameDataQuality::Epic,
            4 => GameDataQuality::Legendary,
            _ => GameDataQuality::Common,
        }
    }
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(C)]
pub enum GameDataQuality {
    #[default]
    Common = 0,
    CommonPlus = 1,
    Epic = 2,
    EpicPlus = 3,
    Iconic = 4,
    Legendary = 5,
    LegendaryPlus = 6,
    LegendaryPlusPlus = 7,
    Random = 8,
    Rare = 9,
    RarePlus = 10,
    Uncommon = 11,
    UncommonPlus = 12,
    Count = 13,
    Invalid = 14,
}

unsafe impl NativeRepr for GameDataQuality {
    const NAME: &'static str = "gamedataQuality";
}

#[derive(Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(i64)]
#[non_exhaustive]
pub enum GameDataStatType {
    #[default]
    ADSSpeedPercentBonus = 0,
    Quality = 1166,
}

unsafe impl NativeRepr for GameDataStatType {
    const NAME: &'static str = "gamedataStatType";
}
