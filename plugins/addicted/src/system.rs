use cp2077_rs::{GameTime, Housing, TimeSystem};
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::interop::{Consumptions, SubstanceId};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.System";
}

#[redscript_import]
impl System {
    fn consumptions(&self) -> Consumptions;
    fn time_system(&self) -> TimeSystem;
    fn resting_since(&self) -> GameTime;
}

impl System {
    pub fn on_ingested_item(&self, item: ItemId) {
        info!("consuming {item:#?}");
        if let Some(id) = SubstanceId::try_from(item).ok() {
            info!("item is addictive");
            self.consumptions()
                .increase(id, self.time_system().get_game_time_stamp());
        }
    }
    pub fn on_status_effect_not_applied_on_spawn(&self, effect: TweakDbId) {
        if effect.is_housing() {
            info!("housing: {effect:#?}");
            if effect.is_sleep() {
                let since = self.resting_since();
                let now = self.time_system().get_game_time();
                if now < since.add_hours(6) {
                    return;
                }
            }
            self.consumptions().decrease();
        }
    }
}
