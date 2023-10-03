use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, IScriptable, Ref},
};

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
}
