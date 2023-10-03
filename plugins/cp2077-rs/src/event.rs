use red4ext_rs::{
    prelude::{RefRepr, Strong},
    types::{IScriptable, Ref},
};

use crate::{FromTypedRef, TypedRef};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Event(Ref<IScriptable>);

unsafe impl RefRepr for Event {
    type Type = Strong;
    const CLASS_NAME: &'static str = "redEvent";
}

impl From<Ref<IScriptable>> for Event {
    fn from(value: Ref<IScriptable>) -> Self {
        Self(value.clone())
    }
}

impl FromTypedRef<Event> for Event {
    fn from_typed_ref(reference: TypedRef<Self>) -> Self {
        Self(reference.into_inner())
    }
}
