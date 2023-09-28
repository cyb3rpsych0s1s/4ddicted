use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.System";
}

#[redscript_import]
impl System {
    pub fn hello_world(&self) -> ();
}