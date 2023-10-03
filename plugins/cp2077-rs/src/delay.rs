use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, Ref},
};

use crate::{FromTypedRef, TypedRef};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct DelaySystem(Ref<IScriptable>);

unsafe impl RefRepr for DelaySystem {
    const CLASS_NAME: &'static str = "gameDelaySystem";

    type Type = Strong;
}

#[redscript_import]
impl DelaySystem {
    /// `public native DelayCallbackNextFrame(delayCallback: DelayCallback): Void`
    #[redscript(native)]
    pub fn delay_callback_next_frame(&self, callback: DelayCallback) -> ();
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct DelayCallback(Ref<IScriptable>);

unsafe impl RefRepr for DelayCallback {
    const CLASS_NAME: &'static str = "gameDelaySystemScriptedDelayCallbackWrapper";

    type Type = Strong;
}

impl FromTypedRef<DelayCallback> for DelayCallback {
    fn from_typed_ref(reference: TypedRef<Self>) -> Self {
        Self(reference.into_inner())
    }
}
