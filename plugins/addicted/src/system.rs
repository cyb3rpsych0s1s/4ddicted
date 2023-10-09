use cp2077_rs::{
    get_all_blackboard_defs, BlackboardIdUint, DelayCallback, DelaySystem,
    EquipmentSystemPlayerData, Event, GameDataEquipmentArea, GameTime, Housing,
    InventoryDataManagerV2, PlayerPuppet, RPGManager, ScriptedPuppet, TimeSystem,
    TransactionSystem,
};
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::board::AddictedBoard;
use crate::interop::{Consumptions, Substance, SubstanceId};
use crate::symptoms::WithdrawalSymptoms;

#[derive(Debug)]
pub struct System;

impl ClassType for System {
    type BaseClass = IScriptable;
    const NAME: &'static str = "Addicted.System";
}

#[derive(Debug)]
pub struct ConsumeEvent;

impl ClassType for ConsumeEvent {
    type BaseClass = Event;
    const NAME: &'static str = "Addicted.ConsumeEvent";
}

#[derive(Debug)]
pub struct ConsumeCallback;

impl ClassType for ConsumeCallback {
    type BaseClass = DelayCallback;
    const NAME: &'static str = "Addicted.ConsumeCallback";
}

#[redscript_import]
impl System {
    fn consumptions(self: &Ref<Self>) -> Ref<Consumptions>;
    fn player(self: &Ref<Self>) -> Ref<PlayerPuppet>;
    fn time_system(self: &Ref<Self>) -> Ref<TimeSystem>;
    fn transaction_system(self: &Ref<Self>) -> Ref<TransactionSystem>;
    fn delay_system(self: &Ref<Self>) -> Ref<DelaySystem>;
    fn resting_since(self: &Ref<Self>) -> GameTime;
    fn create_consume_event(self: &Ref<Self>, message: RedString) -> Ref<ConsumeEvent>;
    fn create_consume_callback(self: &Ref<Self>, message: RedString) -> Ref<ConsumeCallback>;
    fn get_equip_area_type(self: &Ref<Self>, item: ItemId) -> GameDataEquipmentArea;
}

impl System {
    fn withdrawal_symptoms(&self) -> BlackboardIdUint {
        get_all_blackboard_defs()
            .player_state_machine()
            .withdrawal_symptoms()
    }
}

impl System {
    pub fn on_ingested_item(self: Ref<Self>, item: ItemId) {
        info!("consuming {item:#?}");
        if let Ok(id) = item.try_into() {
            info!("item is addictive");
            info!(
                "item quality: {:#?}",
                self.transaction_system()
                    .get_item_data(
                        red4ext_rs::prelude::Ref::<ScriptedPuppet>::upcast(
                            red4ext_rs::prelude::Ref::<PlayerPuppet>::upcast(self.player())
                        ),
                        item
                    )
                    .upgrade()
                    .expect("couldn't get item data")
                    .get_quality()
            );
            self.consumptions()
                .increase(id, self.time_system().get_game_time_stamp());
            self.update_symptom(id);
            let message = RedString::new("Hello from System");
            let evt = self.create_consume_event(message.clone());
            self.player()
                .queue_event(red4ext_rs::prelude::Ref::<ConsumeEvent>::upcast(evt));
            let callback = self.create_consume_callback(message);
            self.delay_system()
                .delay_callback_next_frame(red4ext_rs::prelude::Ref::<ConsumeCallback>::upcast(
                    callback,
                ));
        }
    }
    pub fn on_status_effect_not_applied_on_spawn(self: Ref<Self>, effect: TweakDbId) {
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
    pub fn on_unequip_item(
        self: Ref<Self>,
        data: Ref<EquipmentSystemPlayerData>,
        equip_area_index: i32,
        slot_index: i32,
        force_remove: bool,
    ) {
        let owner = data.get_owner();
        info!("got owner");
        if let Some(player) = owner.upgrade() {
            info!("scripted puppet can indeed be converted into player puppet");
            if let Some(item) = data.get_item(equip_area_index, slot_index) {
                info!("got item in slot");
                let area = self.get_equip_area_type(item);
                info!("got equip area ({area:#?})");
                let cyberware = InventoryDataManagerV2::is_equipment_area_cyberware(area);
                info!("checked area");
                if cyberware {
                    info!("area is indeed a cyberware");
                    let data = RPGManager::get_item_data(
                        red4ext_rs::prelude::Ref::<ScriptedPuppet>::upcast(player.clone())
                            .get_game(),
                        red4ext_rs::prelude::Ref::<ScriptedPuppet>::upcast(player),
                        item,
                    );
                    info!("got item data");
                    if !force_remove
                        && data
                            .upgrade()
                            .map(|x| x.has_tag(CName::new("UnequipBlocked")))
                            .unwrap_or(false)
                    {
                        info!("special condition to bail out");
                        return;
                    }
                    info!("reached point of interest");
                    // TODO
                    // filter cyberwares of interest
                    // update cyberware status
                }
            }
        }
    }
    #[inline]
    pub fn is_withdrawing_from_substance(self: &Ref<Self>, substance: Substance) -> bool {
        self.consumptions()
            .is_withdrawing_from_substance(substance, self.time_system().get_game_time())
    }
    pub fn slept_under_influence(self: &Ref<Self>) -> bool {
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
    fn update_symptom(self: &Ref<Self>, id: SubstanceId) {
        let board = self.player().get_player_state_machine_blackboard();
        let pin = self.withdrawal_symptoms();
        let current = board.get_uint(pin.clone());
        let current = WithdrawalSymptoms::from_bits_truncate(current);
        let symptom = WithdrawalSymptoms::from(id);
        let mut next = current;
        next.remove(symptom);
        if current != next {
            board.set_uint(pin.clone(), next.bits(), false);
        }
        info!("withdrawal symptoms before {current:#034b} after {next:#034b}");
    }
    fn update_symptoms(self: &Ref<Self>) {
        let board = self.player().get_player_state_machine_blackboard();
        let pin = self.withdrawal_symptoms();
        let current = board.get_uint(pin.clone());
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
            board.set_uint(pin.clone(), next.bits(), true);
        }
        info!("withdrawal symptoms before {current:#034b} after {next:#034b}");
    }
}
