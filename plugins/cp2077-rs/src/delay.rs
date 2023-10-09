use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, Ref},
};

#[derive(Debug)]
pub struct DelaySystem;

impl ClassType for DelaySystem {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameDelaySystem";
}

#[redscript_import]
impl DelaySystem {
    /// `public native DelayCallbackNextFrame(delayCallback: DelayCallback): Void`
    #[redscript(native)]
    pub fn delay_callback_next_frame(self: &Ref<Self>, callback: Ref<DelayCallback>) -> ();
}

#[derive(Debug)]
pub struct DelayCallback;

impl ClassType for DelayCallback {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gameDelaySystemScriptedDelayCallbackWrapper";
}
