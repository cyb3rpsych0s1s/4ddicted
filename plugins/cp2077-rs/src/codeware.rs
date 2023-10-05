use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, IScriptable, Ref, Variant},
};

use crate::IsDefined;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Reflection(pub Ref<IScriptable>);

unsafe impl RefRepr for Reflection {
    const CLASS_NAME: &'static str = "Reflection";
    type Type = Strong;
}

#[redscript_import]
impl Reflection {
    /// `public static native func GetClass(name: CName) -> ref<ReflectionClass>`
    #[redscript(native, name = "GetClass")]
    pub fn inner_get_class(name: CName) -> ReflectionClass;
}

impl Reflection {
    pub fn get_class(&self, name: CName) -> ReflectionClass {
        Self::inner_get_class(name)
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionClass(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionClass {
    const CLASS_NAME: &'static str = "ReflectionClass";
    type Type = Strong;
}

#[redscript_import]
impl ReflectionClass {
    /// `public native func GetAlias() -> CName`
    #[redscript(native)]
    pub fn get_alias(&self) -> CName;

    /// `public native func GetProperty(name: CName) -> ref<ReflectionProp>`
    #[redscript(native)]
    pub fn get_property(&self, name: CName) -> ReflectionProp;
}

impl IsDefined for ReflectionClass {
    fn is_defined(&self) -> bool {
        !self.0.clone().into_shared().as_ptr().is_null()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionProp(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionProp {
    const CLASS_NAME: &'static str = "ReflectionProp";
    type Type = Strong;
}

#[redscript_import]
impl ReflectionProp {
    /// `public native func GetValue(owner: Variant) -> Variant`
    #[redscript(native)]
    pub fn get_value(&self, owner: Variant) -> Variant;

    /// `public native func SetValue(owner: Variant, value: Variant) -> Void`
    #[redscript(native)]
    pub fn set_value(&self, owner: Variant, value: Variant) -> ();
}

impl IsDefined for ReflectionProp {
    fn is_defined(&self) -> bool {
        !self.0.clone().into_shared().as_ptr().is_null()
    }
}
