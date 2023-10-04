use red4ext_rs::{
    prelude::{redscript_global, redscript_import, NativeRepr, RefRepr, Strong},
    types::{CName, IScriptable, Ref},
};

use crate::Reflection;

/// `public static native func GetAllBlackboardDefs() -> AllBlackboardDefinitions`
#[redscript_global(native)]
pub fn get_all_blackboard_defs() -> AllBlackboardDefinitions;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct AllBlackboardDefinitions(Ref<IScriptable>);

unsafe impl RefRepr for AllBlackboardDefinitions {
    const CLASS_NAME: &'static str = "gamebbAllScriptDefinitions";
    type Type = Strong;
}

#[cfg(feature = "codeware")]
impl AllBlackboardDefinitions {
    pub fn player_state_machine(&self) -> PlayerStateMachineDef {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        let field = cls.get_property(CName::new("PlayerStateMachine"));
        VariantExt::try_get(&field.get_value(VariantExt::new(self.clone())))
            .expect("prop PlayerStateMachine of type PlayerStateMachineDef")
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct PlayerStateMachineDef(Ref<IScriptable>);

unsafe impl RefRepr for PlayerStateMachineDef {
    const CLASS_NAME: &'static str = "PlayerStateMachineDef";
    type Type = Strong;
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct Id {
    pub g: CName,
}

unsafe impl NativeRepr for Id {
    const NAME: &'static str = "gamebbID";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct BlackboardId {
    pub unk00: [u8; 8],
    pub none: Id,
}

unsafe impl NativeRepr for BlackboardId {
    const NAME: &'static str = "BlackboardID";
    const NATIVE_NAME: &'static str = "gamebbScriptID";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct BlackboardIdUint(BlackboardId);

unsafe impl NativeRepr for BlackboardIdUint {
    const NAME: &'static str = "BlackboardID_Uint";
    const NATIVE_NAME: &'static str = "gamebbScriptID_Uint32";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct BlackboardIdBool(BlackboardId);

unsafe impl NativeRepr for BlackboardIdBool {
    const NAME: &'static str = "BlackboardID_Bool";
    const NATIVE_NAME: &'static str = "gamebbScriptID_Bool";
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct IBlackboard(Ref<IScriptable>);

unsafe impl RefRepr for IBlackboard {
    const CLASS_NAME: &'static str = "gameIBlackboard";
    type Type = Strong;
}

#[redscript_import]
impl IBlackboard {
    /// `public native GetUint(id: BlackboardID_Uint): Uint32`
    #[redscript(native)]
    pub fn get_uint(&self, id: BlackboardIdUint) -> u32;
    /// `public native SetUint(id: BlackboardID_Uint, value: Uint32, opt forceFire: Bool): Void`
    #[redscript(native)]
    pub fn set_uint(&self, id: BlackboardIdUint, value: u32, force_fire: bool) -> ();

    /// `public native GetBool(id: BlackboardID_Bool): Bool`
    #[redscript(native)]
    pub fn get_bool(&self, id: BlackboardIdBool) -> bool;
    /// `public native SetBool(id: BlackboardID_Bool, value: Bool, opt forceFire: Bool): Void`
    #[redscript(native)]
    pub fn set_bool(&self, id: BlackboardIdBool, value: bool, force_fire: bool) -> ();
    /// `public native SignalBool(id: BlackboardID_Bool): Void`
    #[redscript(native)]
    pub fn signal_bool(&self, id: BlackboardIdBool) -> ();
}
