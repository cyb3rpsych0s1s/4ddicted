use red4ext_rs::{types::{Ref, IScriptable}, prelude::{RefRepr, Strong}};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Event(pub Ref<IScriptable>);

unsafe impl RefRepr for Event {
    type Type = Strong;
    const CLASS_NAME: &'static str = "redEvent";
}