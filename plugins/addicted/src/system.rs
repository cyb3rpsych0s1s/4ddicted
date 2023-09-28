use red4ext_rs::{types::{Ref, IScriptable}, prelude::{Strong, RefRepr}};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;
    
    const CLASS_NAME: &'static str = "Addicted.System";
}