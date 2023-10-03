use crate::{Event, GameObject, IBlackboard};
use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, Ref},
};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct PlayerPuppet(Ref<IScriptable>);

unsafe impl RefRepr for PlayerPuppet {
    type Type = Strong;

    const CLASS_NAME: &'static str = "PlayerPuppet";
}

impl PlayerPuppet {
    pub fn as_game_object(&mut self) -> GameObject {
        GameObject(self.0.clone())
    }
}

#[redscript_import]
impl PlayerPuppet {
    /// `public func GetPlayerStateMachineBlackboard() -> IBlackboard`
    pub fn get_player_state_machine_blackboard(&self) -> IBlackboard;

    /// `public final native func QueueEvent(evt: ref<Event>) -> Void;`
    #[redscript(native)]
    pub fn queue_event(&self, evt: Event) -> ();
}
