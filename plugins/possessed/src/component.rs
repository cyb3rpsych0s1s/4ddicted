use cp2077_rs::{IComponent, IntoTypedRef, TypedRef};
use red4ext_rs::{types::{Ref, IScriptable}, prelude::{RefRepr, Strong}};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct GimmickComponent(Ref<IScriptable>);

unsafe impl RefRepr for GimmickComponent {
    const CLASS_NAME: &'static str = "Possessed.GimmickComponent";
    type Type = Strong;
}

unsafe impl IntoTypedRef<IComponent> for GimmickComponent {
    fn into_typed_ref(self) -> TypedRef<IComponent> {
        TypedRef::new(self.0)
    }
}
