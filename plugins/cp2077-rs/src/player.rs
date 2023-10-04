use crate::{defined::IsDefined, Event, GameInstance, GameObject, IBlackboard};
use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, IScriptable, Ref, WRef},
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
    /// `public final native const func GetGame() -> GameInstance;`
    #[redscript(native)]
    pub fn get_game(&self) -> GameInstance;

    /// `public func GetPlayerStateMachineBlackboard() -> IBlackboard`
    pub fn get_player_state_machine_blackboard(&self) -> IBlackboard;

    /// `public final native func QueueEvent(evt: ref<Event>) -> Void;`
    #[redscript(native)]
    pub fn queue_event(&self, evt: Event) -> ();
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ScriptedPuppet(WRef<IScriptable>);

unsafe impl RefRepr for ScriptedPuppet {
    const CLASS_NAME: &'static str = "ScriptedPuppet";
    type Type = Strong;
}

impl TryFrom<ScriptedPuppet> for PlayerPuppet {
    type Error = super::Error;

    fn try_from(value: ScriptedPuppet) -> Result<Self, Self::Error> {
        if value.is_exactly_a(CName::new(PlayerPuppet::CLASS_NAME)) && value.0.is_defined() {
            use red4ext_rs::types::RefShared;
            let raw = value.0.into_shared();
            let handle =
                unsafe { std::mem::transmute::<RefShared<IScriptable>, Ref<IScriptable>>(raw) };
            return Ok(PlayerPuppet(handle));
        }
        Err(super::Error::Incompatible)
    }
}

#[redscript_import]
impl ScriptedPuppet {
    /// `public native IsExactlyA(className: CName): Bool`
    #[redscript(native)]
    pub fn is_exactly_a(&self, cls: CName) -> bool;
}
