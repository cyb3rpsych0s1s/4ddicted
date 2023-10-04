use cp2077_rs::{get_all_blackboard_defs, BlackboardIdBool, PlayerPuppet};
use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, Ref},
};

use crate::board::StupefiedBoard;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;
    const CLASS_NAME: &'static str = "Stupefied.System";
}

#[redscript_import]
impl System {
    fn player(&self) -> PlayerPuppet;
}

impl System {
    /// disable voice whenever consuming item
    pub fn on_consuming_item(self) {
        self.update_consuming(true);
    }
    /// re-enable voice whenever status effect applied
    /// (when status effect is applied, it means the item has been consumed already)
    pub fn on_consumed_item(self) {
        self.update_consuming(false);
    }
    #[inline]
    fn update_consuming(self, value: bool) {
        let board = self.player().get_player_state_machine_blackboard();
        let pin = self.is_consuming();
        let current = board.get_bool(pin.clone());
        if current != value {
            board.set_bool(pin.clone(), value, true);
        }
    }
}

impl System {
    fn is_consuming(&self) -> BlackboardIdBool {
        get_all_blackboard_defs()
            .player_state_machine()
            .is_consuming()
    }
}
