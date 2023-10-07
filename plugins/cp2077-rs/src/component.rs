use red4ext_rs::{types::{Ref, IScriptable}, prelude::{RefRepr, Strong}};

use crate::{TypedRef, FromTypedRef};

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
