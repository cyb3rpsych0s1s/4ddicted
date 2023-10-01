use cp2077_rs::{GameTime, Housing, TimeSystem, TransactionSystem};
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::interop::{Category, Consumptions, Substance, SubstanceId};
use crate::player::PlayerPuppet;

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
    fn player(&self) -> PlayerPuppet;
    fn time_system(&self) -> TimeSystem;
    fn transaction_system(&self) -> TransactionSystem;
    fn resting_since(&self) -> GameTime;
}

impl System {
    pub fn on_ingested_item(&self, item: ItemId) {
        info!("consuming {item:#?}");
        if let Some(id) = SubstanceId::try_from(item).ok() {
            info!("item is addictive");
            info!(
                "item quality: {:#?}",
                self.transaction_system()
                    .get_item_data(self.player().as_game_object(), item)
                    .get_quality()
            );
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
                if self.slept_under_influence() {
                    return;
                }
            }
            self.consumptions().decrease();
        }
    }
    #[allow(dead_code)]
    pub fn is_withdrawing_from_substance(&self, substance: Substance) -> bool {
        for ref consumption in self.consumptions().by_substance(substance) {
            if let Some(last) = consumption.doses().last() {
                let last = GameTime::from(*last);
                let now = self.time_system().get_game_time();
                return now >= last.add_hours(24);
            }
        }
        false
    }
    #[allow(dead_code)]
    pub fn is_withdrawing_from_category(&self, category: Category) -> bool {
        for substance in <&[Substance]>::from(category).iter() {
            if self.is_withdrawing_from_substance(*substance) {
                return true;
            }
        }
        false
    }
    pub fn slept_under_influence(&self) -> bool {
        let since = self.resting_since();
        for ref id in self.consumptions().keys() {
            if let Some(ref consumption) = self.consumptions().get(*id) {
                if let Some(last) = consumption.doses().last() {
                    let last = GameTime::from(*last);
                    if since < last.add_hours(2) {
                        return true;
                    }
                }
            }
        }
        false
    }
}
