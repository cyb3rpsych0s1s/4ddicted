use cp2077_rs::{
    get_all_blackboard_defs, BlackboardIdUint, DelayCallback, DelaySystem, Downcast,
    EquipmentSystem, EquipmentSystemPlayerData, Event, GameTime, Housing, IntoTypedRef,
    InventoryDataManagerV2, PlayerPuppet, RPGManager, SEquipArea, TimeSystem, TransactionSystem,
    TweakDBInterface, TypedRef,
};
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::board::AddictedBoard;
use crate::interop::{Consumptions, Substance, SubstanceId};
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
    fn create_consume_event(&self, message: RedString) -> ConsumeEvent;
    fn create_consume_callback(&self, message: RedString) -> ConsumeCallback;
}

impl System {
    fn withdrawal_symptoms(&self) -> BlackboardIdUint {
        get_all_blackboard_defs()
            .player_state_machine()
            .withdrawal_symptoms()
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
    pub fn on_send_paperdoll_update(
        self,
        _player_data: EquipmentSystemPlayerData,
        _equipped: bool,
        _area: SEquipArea,
        _slot: i32,
        _force: bool,
    ) {

    }
    // pub fn on_equip_item(
    //     self,
    //     player_data: EquipmentSystemPlayerData,
    //     item: ItemId,
    //     slot_index: i32,
    //     block_active_slots_update: bool,
    //     force_equip_weapon: bool,
    // ) {
    //     let owner = player_data.get_owner();
    //     if let Ok(mut player) = PlayerPuppet::try_from(owner) {
    //         let data = RPGManager::get_item_data(player.get_game(), player.as_game_object(), item);
    //         if player_data.is_equippable(data) { return; }
    //         let record = TweakDBInterface::get_item_record(item.get_tdbid());
    //     }
    // }
    // pub fn on_unequip_item(
    //     self,
    //     player_data: EquipmentSystemPlayerData,
    //     equip_area_index: i32,
    //     slot_index: i32,
    //     force_remove: bool,
    // ) {
    //     use cp2077_rs::IsDefined;
    //     let owner = player_data.get_owner();
    //     info!("got owner");
    //     if let Ok(mut player) = PlayerPuppet::try_from(owner) {
    //         info!("scripted puppet can indeed be converted into player puppet");
    //         if let Some(item) = player_data.get_item(equip_area_index, slot_index) {
    //             info!("got item in slot");
    //             if item == ItemId::default() {
    //                 return;
    //             }
    //             let area = EquipmentSystem::get_instance(player.as_game_object())
    //                 .get_equip_area_type(item);
    //             info!("got equip area");
    //             let cyberware = InventoryDataManagerV2::is_equipment_area_cyberware(area);
    //             info!("checked area");
    //             if cyberware {
    //                 info!("area is indeed a cyberware");
    //                 let data = RPGManager::get_item_data(
    //                     player.clone().get_game(),
    //                     player.as_game_object(),
    //                     item,
    //                 );
    //                 info!("got item data");
    //                 if !force_remove
    //                     && data.is_defined()
    //                     && data.has_tag(CName::new("UnequipBlocked"))
    //                 {
    //                     info!("special condition to bail out");
    //                     return;
    //                 }
    //                 info!("reached point of interest");
    //                 // TODO
    //                 // filter cyberwares of interest
    //                 // update cyberware status
    //             }
    //         }
    //     }
    // }
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
    fn update_symptoms(&self) {
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
