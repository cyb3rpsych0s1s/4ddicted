use std::ffi::c_void;

use red4ext_rs::{
    prelude::{redscript_import, NativeRepr, RefRepr, Strong, Weak},
    types::{CName, IScriptable, Ref, WRef},
};

use crate::defined::IsDefined;

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

unsafe impl RefRepr for GameInstance {
    type Type = Strong;

    const CLASS_NAME: &'static str = "RED4ext::ScriptGameInstance";
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct GameObject(pub Ref<IScriptable>);

unsafe impl RefRepr for GameObject {
    const CLASS_NAME: &'static str = "gameObject";

    type Type = Strong;
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct GameItemData(WRef<IScriptable>);

unsafe impl RefRepr for GameItemData {
    const CLASS_NAME: &'static str = "gameItemData";

    type Type = Weak;
}

#[redscript_import]
impl GameItemData {
    /// `public final native func GetStatValueByType(type: gamedataStatType) -> Float;`
    #[redscript(native)]
    fn get_stat_value_by_type(&self, r#type: GameDataStatType) -> f32;

    /// `public final native const func HasTag(tag: CName) -> Bool;`
    #[redscript(native)]
    pub fn has_tag(&self, tag: CName) -> bool;
}

impl IsDefined for GameItemData {
    fn is_defined(&self) -> bool {
        !self.0.clone().into_shared().as_ptr().is_null()
    }
}

impl GameItemData {
    /// see RPGManager
    ///
    /// `public final static func GetItemQuality(qualityStat: Float) -> gamedataQuality`
    pub fn get_quality(&self) -> GameDataQuality {
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
