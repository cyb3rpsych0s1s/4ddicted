use red4ext_rs::{
    prelude::{redscript_global, redscript_import, ClassType, NativeRepr},
    types::{CName, EntityId, IScriptable, Ref},
};

/// `public static native func GetAllBlackboardDefs() -> AllBlackboardDefinitions`
#[redscript_global(native)]
pub fn get_all_blackboard_defs() -> Ref<AllBlackboardDefinitions>;

#[derive(Debug)]
pub struct BlackboardSystem;

impl ClassType for BlackboardSystem {
    type BaseClass = IScriptable;
    const NAME: &'static str = "BlackboardSystem";
    const NATIVE_NAME: &'static str = "gameBlackboardSystem";
}

#[redscript_import]
impl BlackboardSystem {
    /// `public native Get(definition: BlackboardDefinition): IBlackboard`
    #[redscript(native)]
    pub fn get(self: &Ref<Self>, definition: Ref<BlackboardDefinition>) -> Ref<IBlackboard>;
    /// `public native GetLocalInstanced(entityID: EntityID, definition: BlackboardDefinition): IBlackboard`
    #[redscript(native)]
    pub fn get_local_instanced(
        self: &Ref<Self>,
        entity_id: EntityId,
        definition: Ref<BlackboardDefinition>,
    ) -> Ref<IBlackboard>;
}

#[derive(Debug)]
pub struct BlackboardDefinition;

impl ClassType for BlackboardDefinition {
    type BaseClass = IScriptable;
    const NAME: &'static str = "BlackboardDefinition";
    const NATIVE_NAME: &'static str = "gamebbScriptDefinition";
}

#[derive(Debug)]
pub struct AllBlackboardDefinitions;

impl ClassType for AllBlackboardDefinitions {
    type BaseClass = IScriptable;
    const NAME: &'static str = "AllBlackboardDefinitions";
    const NATIVE_NAME: &'static str = "gamebbAllScriptDefinitions";
}

#[cfg(feature = "codeware")]
impl AllBlackboardDefinitions {
    pub fn player_state_machine(self: &Ref<Self>) -> Ref<PlayerStateMachineDef> {
        use crate::codeware::Field;
        Self::get_field_value(self, "PlayerStateMachine")
    }
    pub fn ui_interactions(self: &Ref<Self>) -> Ref<UIInteractionsDef> {
        use crate::codeware::Field;
        Self::get_field_value(self, "UIInteractions")
    }
}

#[derive(Debug)]
pub struct PlayerStateMachineDef;

impl ClassType for PlayerStateMachineDef {
    type BaseClass = BlackboardDefinition;
    const NAME: &'static str = "PlayerStateMachineDef";
}

#[derive(Debug)]
pub struct UIInteractionsDef;

impl ClassType for UIInteractionsDef {
    type BaseClass = BlackboardDefinition;
    const NAME: &'static str = "UIInteractionsDef";
}

#[derive(Debug, Default, Clone)]
#[repr(C)]
pub struct Id {
    pub g: CName,
}

unsafe impl NativeRepr for Id {
    const NAME: &'static str = "gamebbID";
}

#[derive(Debug, Default, Clone)]
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

#[derive(Debug, Default, Clone)]
#[repr(C)]
pub struct BlackboardIdInt(BlackboardId);

unsafe impl NativeRepr for BlackboardIdInt {
    const NAME: &'static str = "BlackboardID_Int";
    const NATIVE_NAME: &'static str = "gamebbScriptID_Int32";
}

#[derive(Debug, Default, Clone)]
#[repr(C)]
pub struct BlackboardIdBool(BlackboardId);

unsafe impl NativeRepr for BlackboardIdBool {
    const NAME: &'static str = "BlackboardID_Bool";
    const NATIVE_NAME: &'static str = "gamebbScriptID_Bool";
}

#[derive(Debug, Default, Clone)]
#[repr(C)]
pub struct BlackboardIdVariant(BlackboardId);

unsafe impl NativeRepr for BlackboardIdVariant {
    const NAME: &'static str = "BlackboardID_Variant";
    const NATIVE_NAME: &'static str = "gamebbScriptID_Variant";
}

#[derive(Debug)]
pub struct IBlackboard;

impl ClassType for IBlackboard {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameIBlackboard";
}

#[redscript_import]
impl IBlackboard {
    /// `public native RegisterListenerInt(id: BlackboardID_Int, object: IScriptable, func: CName, opt fireIfValueExist: Bool): CallbackHandle`
    pub fn register_listener_int(
        self: &Ref<Self>,
        id: BlackboardIdInt,
        object: Ref<IScriptable>,
        func: CName,
        fire_if_value_exist: bool,
    ) -> Ref<CallbackHandle>;
    /// `public native UnregisterListenerInt(id: BlackboardID_Int, out callbackHandle: CallbackHandle): Void`
    pub fn unregister_listener_int(
        self: &Ref<Self>,
        id: BlackboardIdInt,
        callback_handle: Ref<CallbackHandle>,
    ) -> ();

    /// `public native GetUint(id: BlackboardID_Uint): Uint32`
    #[redscript(native)]
    pub fn get_uint(self: &Ref<Self>, id: BlackboardIdUint) -> u32;
    /// `public native SetUint(id: BlackboardID_Uint, value: Uint32, opt forceFire: Bool): Void`
    #[redscript(native)]
    pub fn set_uint(self: &Ref<Self>, id: BlackboardIdUint, value: u32, force_fire: bool) -> ();

    /// `public native GetBool(id: BlackboardID_Bool): Bool`
    #[redscript(native)]
    pub fn get_bool(self: &Ref<Self>, id: BlackboardIdBool) -> bool;
    /// `public native SetBool(id: BlackboardID_Bool, value: Bool, opt forceFire: Bool): Void`
    #[redscript(native)]
    pub fn set_bool(self: &Ref<Self>, id: BlackboardIdBool, value: bool, force_fire: bool) -> ();
    /// `public native SignalBool(id: BlackboardID_Bool): Void`
    #[redscript(native)]
    pub fn signal_bool(self: &Ref<Self>, id: BlackboardIdBool) -> ();

    /// `public native RegisterDelayedListenerVariant(id: BlackboardID_Variant, object: IScriptable, func: CName, opt fireIfValueExist: Bool): CallbackHandle`
    #[redscript(native)]
    pub fn register_delayed_listener_variant(
        self: &Ref<Self>,
        id: BlackboardIdVariant,
        object: Ref<IScriptable>,
        func: CName,
        fire_if_value_exist: bool,
    ) -> Ref<CallbackHandle>;
    /// `public native UnregisterListenerVariant(id: BlackboardID_Variant, out callbackHandle: CallbackHandle): Void`
    #[redscript(native)]
    pub fn unregister_listener_variant(
        self: &Ref<Self>,
        id: BlackboardIdVariant,
        callback_handle: Ref<CallbackHandle>,
    ) -> ();
}

#[derive(Debug)]
pub struct CallbackHandle;

impl ClassType for CallbackHandle {
    type BaseClass = IScriptable;
    const NAME: &'static str = "CallbackHandle";
    const NATIVE_NAME: &'static str = "redCallbackObject";
}
