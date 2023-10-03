use cp2077_rs::{
    get_all_blackboard_defs, BlackboardIdBool, BlackboardIdUint, DelayCallback, DelaySystem,
    Downcast, Event, GameTime, Housing, IntoTypedRef, TimeSystem, TransactionSystem, TypedRef,
};
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::board::CustomBoard;
use crate::interop::{Consumptions, Substance, SubstanceId};
use crate::player::PlayerPuppet;
use crate::symptoms::WithdrawalSymptoms;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.System";
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ConsumeEvent(Ref<IScriptable>);

unsafe impl RefRepr for ConsumeEvent {
    type Type = Strong;
    const CLASS_NAME: &'static str = "Addicted.ConsumeEvent";
}

unsafe impl IntoTypedRef<Event> for ConsumeEvent {
    fn into_typed_ref(self) -> TypedRef<Event> {
        TypedRef::new(self.0)
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ConsumeCallback(Ref<IScriptable>);

unsafe impl RefRepr for ConsumeCallback {
    type Type = Strong;
    const CLASS_NAME: &'static str = "Addicted.ConsumeCallback";
}

unsafe impl IntoTypedRef<DelayCallback> for ConsumeCallback {
    fn into_typed_ref(self) -> TypedRef<DelayCallback> {
        TypedRef::new(self.0)
    }
}

#[redscript_import]
impl System {
    fn consumptions(&self) -> Consumptions;
    fn player(&self) -> PlayerPuppet;
    fn time_system(&self) -> TimeSystem;
    fn transaction_system(&self) -> TransactionSystem;
    fn delay_system(&self) -> DelaySystem;
    fn resting_since(&self) -> GameTime;
    fn is_consuming(&self) -> BlackboardIdBool;
    fn create_consume_event(&self, message: RedString) -> ConsumeEvent;
    fn create_consume_callback(&self, message: RedString) -> ConsumeCallback;
}

impl System {
    fn withdrawal_symptoms(&self) -> BlackboardIdUint {
        info!("about to request blackboard defs");
        let defs = get_all_blackboard_defs();
        info!("about to request PSM");
        let psm = defs.player_state_machine();
        info!("about to request custom field (WithdrawalSymptoms)");

        psm.withdrawal_symptoms()
    }
}

impl System {
    pub fn on_ingested_item(self, item: ItemId) {
        info!("consuming {item:#?}");
        if let Ok(id) = item.try_into() {
            info!("item is addictive");
            info!(
                "item quality: {:#?}",
                self.transaction_system()
                    .get_item_data(self.player().as_game_object(), item)
                    .get_quality()
            );
            self.consumptions()
                .increase(id, self.time_system().get_game_time_stamp());
            self.update_symptom(id);
            let message = RedString::new("Hello from System");
            let evt = self.create_consume_event(message.clone());
            self.player().queue_event(evt.downcast());
            let callback = self.create_consume_callback(message);
            self.delay_system()
                .delay_callback_next_frame(callback.downcast());
        }
    }
    pub fn on_status_effect_not_applied_on_spawn(self, effect: TweakDbId) {
        if effect.is_housing() {
            info!("housing: {effect:#?}");
            let mut weanoff = true;
            if effect.is_sleep() {
                let since: GameTime = self.resting_since();
                let now = self.time_system().get_game_time();
                if now < since.add_hours(6) {
                    info!("light sleep");
                    weanoff = false;
                }
                if self.slept_under_influence() {
                    info!("slept under influence");
                    weanoff = false;
                }
            }
            if weanoff {
                self.consumptions().decrease();
            }
            self.update_symptoms();
        }
    }
    #[inline]
    pub fn is_withdrawing_from_substance(&self, substance: Substance) -> bool {
        self.consumptions()
            .is_withdrawing_from_substance(substance, self.time_system().get_game_time())
    }
    pub fn slept_under_influence(&self) -> bool {
        let since = self.resting_since();
        for ref id in self.consumptions().keys() {
            if let Some(ref consumption) = self.consumptions().get_owned(*id) {
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
    fn update_symptom(&self, id: SubstanceId) {
        let board = self.player().get_player_state_machine_blackboard();
        let current = board.get_uint(self.withdrawal_symptoms());
        let current = WithdrawalSymptoms::from_bits_truncate(current);
        let symptom = WithdrawalSymptoms::from(id);
        let mut next = current;
        next.remove(symptom);
        if current != next {
            board.set_uint(self.withdrawal_symptoms(), next.bits(), false);
        }
        info!("withdrawal symptoms before {current:#034b} after {next:#034b}");
    }
    fn update_symptoms(&self) {
        let board = self.player().get_player_state_machine_blackboard();
        let current = board.get_uint(self.withdrawal_symptoms());
        let current = WithdrawalSymptoms::from_bits_truncate(current);
        let mut next = WithdrawalSymptoms::empty();
        for flag in WithdrawalSymptoms::all().iter() {
            if let Some(substance) = flag.substance() {
                if !current.contains(flag) && self.is_withdrawing_from_substance(substance) {
                    next.insert(flag);
                }
            }
        }
        if current != next {
            board.set_uint(self.withdrawal_symptoms(), next.bits(), true);
        }
        info!("withdrawal symptoms before {current:#034b} after {next:#034b}");
    }
}
