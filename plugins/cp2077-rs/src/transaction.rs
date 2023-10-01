use red4ext_rs::{
    prelude::{redscript_import, NativeRepr, RefRepr, Strong, Weak},
    types::{IScriptable, ItemId, Ref, WRef},
};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct TransactionSystem(Ref<IScriptable>);

unsafe impl RefRepr for TransactionSystem {
    const CLASS_NAME: &'static str = "gameTransactionSystem";

    type Type = Strong;
}

#[redscript_import]
impl TransactionSystem {
    /// `public final native func GetItemData(obj: ref<GameObject>, itemID: ItemID) -> wref<gameItemData>`
    #[redscript(native)]
    pub fn get_item_data(&self, obj: GameObject, item: ItemId) -> GameItemData;
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
    /// public final native func GetStatValueByType(type: gamedataStatType) -> Float;
    #[redscript(native)]
    fn get_stat_value_by_type(&self, r#type: GameDataStatType) -> f32;
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
pub enum GameDataStatType {
    #[default]
    ADSSpeedPercentBonus = 0,
    Quality = 1166,
}

unsafe impl NativeRepr for GameDataStatType {
    const NAME: &'static str = "gamedataStatType";
}
