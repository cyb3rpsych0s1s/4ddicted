use cp2077_rs::{
    BlackboardIdBool, BlackboardIdUint, GameTime, Housing, TimeSystem, TransactionSystem,
};
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::interop::Consumptions;
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
    fn withdrawal_symptoms(&self) -> BlackboardIdUint;
    fn is_consuming(&self) -> BlackboardIdBool;
}

impl System {
    pub fn on_ingested_item(&self, item: ItemId) {
        info!("consuming {item:#?}");
        if let Some(id) = item.try_into().ok() {
            info!("item is addictive");
            info!(
                "item quality: {:#?}",
                self.transaction_system()
                    .get_item_data(self.player().as_game_object(), item)
                    .get_quality()
            );
            self.consumptions()
                .increase(id, self.time_system().get_game_time_stamp());
            // self.on_consumed(id);
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
                // if self.slept_under_influence() {
                //     return;
                // }
            }
            self.consumptions().decrease();
            // self.on_rested();
        }
    }
    // #[inline]
    // pub fn is_withdrawing_from_substance(&self, substance: Substance) -> bool {
    //     self.consumptions().is_withdrawing_from_substance(substance)
    // }
    // pub fn slept_under_influence(&self) -> bool {
    //     let since = self.resting_since();
    //     for ref id in self.consumptions().keys() {
    //         if let Some(ref consumption) = self.consumptions().get(*id) {
    //             if let Some(last) = consumption.doses().last() {
    //                 let last = GameTime::from(*last);
    //                 if since < last.add_hours(2) {
    //                     return true;
    //                 }
    //             }
    //         }
    //     }
    //     false
    // }
    // fn on_consumed(&self, id: SubstanceId) {
    //     let board = self.player().get_player_state_machine_blackboard();
    //     let current = board.get_uint(self.withdrawal_symptoms());
    //     let current = WithdrawalSymptoms::from_bits_truncate(current);
    //     let symptom = WithdrawalSymptoms::from(id);
    //     let mut next = current.clone();
    //     next.set(symptom, false);
    //     if current != next {
    //         board.set_uint(self.withdrawal_symptoms(), next.bits(), false);
    //     }
    // }
    // fn on_rested(&self) {
    //     return;
    //     let board = self.player().get_player_state_machine_blackboard();
    //     let current = board.get_uint(self.withdrawal_symptoms());
    //     let current = WithdrawalSymptoms::from_bits_truncate(current);
    //     let mut next = WithdrawalSymptoms::empty();
    //     next.set(
    //         WithdrawalSymptoms::ALCOHOL,
    //         self.is_withdrawing_from_substance(Substance::Alcohol),
    //     );
    //     next.set(
    //         WithdrawalSymptoms::MAXDOC,
    //         self.is_withdrawing_from_substance(Substance::MaxDOC),
    //     );
    //     // TODO ...
    //     if current != next {
    //         board.set_uint(self.withdrawal_symptoms(), next.bits(), true);
    //     }
    // }
}
