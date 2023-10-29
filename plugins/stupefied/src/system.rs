use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};

use cp2077_rs::{
    get_all_blackboard_defs, reds_dbg, BlackboardDefinition, BlackboardIdBool, BlackboardIdInt,
    BlackboardIdVariant, CallbackHandle, GameInstance, PlayerPuppet, UIInteractionsDef,
};
use lazy_static::lazy_static;
use red4ext_rs::{
    info,
    prelude::{redscript_import, ClassType},
    types::{CName, IScriptable, Ref},
};

use crate::board::StupefiedBoard;

#[derive(Debug)]
pub struct CompanionSystem;

impl ClassType for CompanionSystem {
    type BaseClass = IScriptable;
    const NAME: &'static str = "Stupefied.CompanionSystem";
}

#[redscript_import]
impl CompanionSystem {
    fn player(self: &Ref<Self>) -> Ref<PlayerPuppet>;
}

impl CompanionSystem {
    pub fn on_attach(mut self: Ref<Self>) {
        let system = ::cp2077_rs::GameInstance::get_blackboard_system(self.player().get_game());
        let definition: ::red4ext_rs::types::Ref<::cp2077_rs::BlackboardDefinition> =
            ::cp2077_rs::Field::get_field_value(&get_all_blackboard_defs(), "PlayerStateMachine");
        let board = system.get_local_instanced(
            self.player().to_entity().get_entity_id(),
            definition.clone(),
        );
        let id: ::cp2077_rs::BlackboardIdInt =
            ::cp2077_rs::Field::get_field_value(&definition, "Combat");
        let handle = board.register_listener_int(
            id,
            ::red4ext_rs::types::Ref::<Self>::upcast(self.clone()),
            ::red4ext_rs::types::CName::new("on_combat_changed"),
            false,
        );
        ::cp2077_rs::Field::set_field_value(&mut self, "onCombat", handle);

        // let system = GameInstance::get_blackboard_system(self.player().get_game());
        // let board = system.get_local_instanced(
        //     self.player().to_entity().get_entity_id(),
        //     Ref::<UIInteractionsDef>::upcast(get_all_blackboard_defs().ui_interactions()),
        // );
        // let reference = board.register_listener_int(
        //     self.id_combat.clone(),
        //     Ref::<Self>::upcast(self.clone()),
        //     CName::new("on_combat_changed"),
        //     true,
        // );
    }
    pub fn on_detach(mut self: Ref<Self>) {
        // let system = GameInstance::get_blackboard_system(self.player().get_game());
        // let board = system.get_local_instanced(
        //     self.player().to_entity().get_entity_id(),
        //     Ref::<UIInteractionsDef>::upcast(get_all_blackboard_defs().ui_interactions()),
        // );

        // board.unregister_listener_int(
        //     self.id_combat.clone(),
        //     reference,
        // );
    }
    pub fn on_combat_changed(value: i32) {
        reds_dbg!("on combat changed called!");
    }
    /// disable voice whenever consuming item
    pub fn on_consuming_item(self: Ref<Self>) {
        self.update_consuming(true);
    }
    /// re-enable voice whenever status effect applied
    /// (when status effect is applied, it means the item has been consumed already)
    pub fn on_consumed_item(self: Ref<Self>) {
        self.update_consuming(false);
    }
    #[inline]
    fn update_consuming(self: Ref<Self>, value: bool) {
        let board = self.player().get_player_state_machine_blackboard();
        let pin = self.is_consuming();
        let current = board.get_bool(pin.clone());
        if current != value {
            info!("updating consuming blackboard: {current} -> {value}");
            board.set_bool(pin.clone(), value, true);
        }
    }
}

impl CompanionSystem {
    fn is_consuming(self: &Ref<Self>) -> BlackboardIdBool {
        get_all_blackboard_defs()
            .player_state_machine()
            .is_consuming()
    }
}
