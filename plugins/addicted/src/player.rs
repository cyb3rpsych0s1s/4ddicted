use cp2077_rs::GameObject;
use red4ext_rs::{
    prelude::{RefRepr, Strong},
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
    pub fn as_game_object(self) -> GameObject {
        GameObject(self.0)
    }
}

// #[redscript_import]
// impl PlayerPuppet {
//     /// `public func GetPlayerStateMachineBlackboard() -> IBlackboard`
//     pub fn get_player_state_machine_blackboard(&self) -> IBlackboard;
// }
