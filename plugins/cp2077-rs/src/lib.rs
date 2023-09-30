use red4ext_rs::{types::{TweakDbId, Ref, IScriptable}, prelude::{RefRepr, Strong, redscript_import}};

pub const HOUSING: [TweakDbId; 3] = [
    TweakDbId::new("HousingStatusEffect.Rested"),
    TweakDbId::new("HousingStatusEffect.Refreshed"),
    TweakDbId::new("HousingStatusEffect.Energized"),
];

pub trait Housing {
    fn is_housing(&self) -> bool;
}

impl Housing for TweakDbId {
    fn is_housing(&self) -> bool {
        HOUSING.contains(self)
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct TimeSystem(Ref<IScriptable>);

unsafe impl RefRepr for TimeSystem {
    const CLASS_NAME: &'static str = "gameTimeSystem";

    type Type = Strong;
}

#[redscript_import]
impl TimeSystem {
    /// `public native GetGameTimeStamp(): Float`
    #[redscript(native)]
    pub fn get_game_time_stamp(&self) -> f32;
}
