use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, IScriptable, Ref},
};

// #[derive(Default, Clone)]
// #[repr(transparent)]
// pub struct Reflection(pub Ref<IScriptable>);

// unsafe impl RefRepr for Reflection {
//     const CLASS_NAME: &'static str = "App::Reflection";
//     type Type = Strong;
// }

// impl Reflection {
//     pub fn new(self) -> Self { self }
// }

// #[redscript_import]
// impl Reflection {
//     /// `public static native func GetClass(name: CName) -> ref<ReflectionClass>`
//     #[redscript(native)]
//     pub fn get_class(name: CName) -> ReflectionClass;
// }

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionClass(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionClass {
    const CLASS_NAME: &'static str = "App::ReflectionClass";
    type Type = Strong;
}

#[redscript_import]
impl ReflectionClass {
    /// `public native func GetAlias() -> CName`
    #[redscript(native)]
    pub fn get_alias(&self) -> CName;
}
