use red4ext_rs::{
    prelude::RefRepr,
    types::{IScriptable, Ref},
};
use std::marker::PhantomData;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct TypedRef<T>(Ref<IScriptable>, PhantomData<T>);

impl<T> TypedRef<T> {
    pub fn new(reference: Ref<IScriptable>) -> Self {
        Self(reference, PhantomData)
    }
    pub fn into_inner(self) -> Ref<IScriptable> {
        self.0
    }
}

/// # Safety
///
/// implementations of this trait are only valid if your implementors are indeed child classes of `Parent`
pub unsafe trait IntoTypedRef<Parent: RefRepr + Default + Clone> {
    /// cast a reference into a parent typed reference
    fn into_typed_ref(self) -> TypedRef<Parent>;
}

pub trait FromTypedRef<Parent: RefRepr + Default + Clone>: Sized {
    /// cast any self typed reference into itself
    fn from_typed_ref(reference: TypedRef<Parent>) -> Self;
}

pub trait Downcast<Parent>: IntoTypedRef<Parent>
where
    Self: IntoTypedRef<Parent>,
    Parent: RefRepr + Default + Clone + FromTypedRef<Parent>,
{
    /// automatically downcast a wrapper over Ref<IScriptable>
    /// into its parent
    fn downcast(self) -> Parent
    where
        Self: Sized,
    {
        Parent::from_typed_ref(self.into_typed_ref())
    }
}

/// automatically implements downcast for any child classes that can be turned into their parent class
impl<Child, Parent> Downcast<Parent> for Child
where
    Self: IntoTypedRef<Parent>,
    Parent: RefRepr + Default + Clone + FromTypedRef<Parent>,
{
}
