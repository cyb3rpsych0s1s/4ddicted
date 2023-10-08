use red4ext_rs::{
    prelude::{RefRepr, Strong},
    types::{IScriptable, Ref},
};

use crate::{FromTypedRef, TypedRef};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct IComponent(Ref<IScriptable>);

unsafe impl RefRepr for IComponent {
    const CLASS_NAME: &'static str = "entIComponent";
    type Type = Strong;
}

impl FromTypedRef<IComponent> for IComponent {
    fn from_typed_ref(reference: TypedRef<Self>) -> Self {
        Self(reference.into_inner())
    }
}
