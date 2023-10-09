use crate::{EquipmentSystem, Event, GameInstance, GameObject, IBlackboard};
use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{CName, Ref},
};

#[derive(Debug)]
pub struct PlayerPuppet;

impl ClassType for PlayerPuppet {
    type BaseClass = ScriptedPuppet;
    const NAME: &'static str = "PlayerPuppet";
}

#[redscript_import]
impl PlayerPuppet {
    /// `public final native const func GetGame() -> GameInstance;`
    #[redscript(native)]
    pub fn get_game(self: &Ref<Self>) -> GameInstance;

    /// `public func GetPlayerStateMachineBlackboard() -> IBlackboard`
    pub fn get_player_state_machine_blackboard(self: &Ref<Self>) -> Ref<IBlackboard>;

    /// `public final native func QueueEvent(evt: ref<Event>) -> Void;`
    #[redscript(native)]
    pub fn queue_event(self: &Ref<Self>, evt: Ref<Event>) -> ();

    /// `private final const func GetEquipmentSystem() -> ref<EquipmentSystem>`
    pub fn get_equipment_system(self: &Ref<Self>) -> Ref<EquipmentSystem>;
}

#[derive(Debug)]
pub struct ScriptedPuppet;

impl ClassType for ScriptedPuppet {
    type BaseClass = GameObject;
    const NAME: &'static str = "ScriptedPuppet";
}

#[redscript_import]
impl ScriptedPuppet {
    /// `public native IsExactlyA(className: CName): Bool`
    #[redscript(native)]
    pub fn is_exactly_a(self: &Ref<Self>, cls: CName) -> bool;
}
