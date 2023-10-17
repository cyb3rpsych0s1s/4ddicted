use cp2077_rs::PlayerPuppet;
use red4ext_rs::{prelude::{ClassType, redscript_import}, types::{IScriptable, Ref}};

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

// impl System {
//     /// disable voice whenever consuming item
//     pub fn on_consuming_item(self: Ref<Self>) {
//         self.update_consuming(true);
//     }
//     /// re-enable voice whenever status effect applied
//     /// (when status effect is applied, it means the item has been consumed already)
//     pub fn on_consumed_item(self: Ref<Self>) {
//         self.update_consuming(false);
//     }
//     #[inline]
//     fn update_consuming(self: Ref<Self>, value: bool) {
//         let board = self.player().get_player_state_machine_blackboard();
//         let pin = self.is_consuming();
//         let current = board.get_bool(pin.clone());
//         if current != value {
//             board.set_bool(pin.clone(), value, true);
//         }
//     }
// }

// impl System {
//     fn is_consuming(self: &Ref<Self>) -> BlackboardIdBool {
//         get_all_blackboard_defs()
//             .player_state_machine()
//             .is_consuming()
//     }
// }
