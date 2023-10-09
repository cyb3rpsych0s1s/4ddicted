use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, IScriptable, RedArray, Ref, ScriptRef, Variant},
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
    fn inner_get_class(name: CName) -> ReflectionClass;
    /// `public static native func GetTypeOf(value: Variant) -> ref<ReflectionType>`
    #[redscript(native, name = "GetTypeOf")]
    fn inner_get_type_of(value: Variant) -> ReflectionType;
    /// `public static native func GetGlobalFunction(name: CName) -> ref<ReflectionStaticFunc>`
    #[redscript(native, name = "GetGlobalFunction")]
    fn inner_get_global_function(name: CName) -> ReflectionStaticFunc;
    /// `public static native func GetGlobalFunctions() -> array<ref<ReflectionStaticFunc>>`
    #[redscript(native, name = "GetGlobalFunctions")]
    fn inner_get_global_functions() -> RedArray<ReflectionStaticFunc>;
}

impl Reflection {
    pub fn get_class(&self, name: CName) -> Option<ReflectionClass> {
        let cls = Self::inner_get_class(name);
        if cls.is_defined() {
            return Some(cls);
        }
        None
    }
    pub fn get_type_of(&self, value: Variant) -> Option<ReflectionType> {
        let ty = Self::inner_get_type_of(value);
        if ty.is_defined() {
            return Some(ty);
        }
        None
    }
    pub fn get_global_function(&self, name: CName) -> Option<ReflectionStaticFunc> {
        let fun = Self::inner_get_global_function(name);
        if fun.is_defined() {
            return Some(fun);
        }
        None
    }
    pub fn get_global_functions(&self) -> RedArray<ReflectionStaticFunc> {
        Self::inner_get_global_functions()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionClass(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionClass {
    const CLASS_NAME: &'static str = "ReflectionClass";
    type Type = Strong;
}

impl ReflectionClass {
    pub fn into_inner(self) -> Ref<IScriptable> {
        self.0
    }
}

impl IsDefined for ReflectionClass {
    fn is_defined(&self) -> bool {
        self.0.is_defined()
    }
}

#[redscript_import]
impl ReflectionClass {
    /// `public native func GetAlias() -> CName`
    #[redscript(native)]
    pub fn get_alias(&self) -> CName;

    /// `public native func GetProperty(name: CName) -> ref<ReflectionProp>`
    #[redscript(native, name = "GetProperty")]
    fn inner_get_property(&self, name: CName) -> ReflectionProp;

    /// `public native func GetStaticFunction(name: CName) -> ref<ReflectionStaticFunc>`
    #[redscript(native, name = "GetStaticFunction")]
    fn inner_get_static_function(&self, name: CName) -> ReflectionStaticFunc;

    /// `public native func GetFunction(name: CName) -> ref<ReflectionMemberFunc>`
    #[redscript(native, name = "GetFunction")]
    fn inner_get_function(&self, name: CName) -> ReflectionMemberFunc;

    /// `public native func GetStaticFunctions() -> array<ref<ReflectionStaticFunc>>`
    #[redscript(native)]
    pub fn get_static_functions(&self) -> RedArray<ReflectionStaticFunc>;

    /// `public native func GetFunctions() -> array<ref<ReflectionMemberFunc>>`
    #[redscript(native)]
    pub fn inner_get_functions(&self) -> RedArray<ReflectionMemberFunc>;
}

impl ReflectionClass {
    pub fn get_property(&self, name: CName) -> Option<ReflectionProp> {
        let field = self.inner_get_property(name);
        if field.is_defined() {
            return Some(field);
        }
        None
    }
    pub fn get_static_function(&self, name: CName) -> Option<ReflectionStaticFunc> {
        let fun = self.inner_get_static_function(name);
        if fun.is_defined() {
            return Some(fun);
        }
        None
    }
    pub fn get_function(&self, name: CName) -> Option<ReflectionMemberFunc> {
        let fun = self.inner_get_function(name);
        if fun.is_defined() {
            return Some(fun);
        }
        None
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
        self.0.is_defined()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionType(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionType {
    const CLASS_NAME: &'static str = "ReflectionType";
    type Type = Strong;
}

impl ReflectionType {
    pub fn into_inner(self) -> Ref<IScriptable> {
        self.0
    }
}

#[redscript_import]
impl ReflectionType {
    /// `public native func GetInnerType() -> ref<ReflectionType>`
    #[redscript(native)]
    pub fn get_inner_type(&self) -> ReflectionType;
    /// `public func AsClass() -> ref<ReflectionClass>`
    pub fn as_class(&self) -> ReflectionClass;
    /// `public native func GetName() -> CName`
    #[redscript(native)]
    pub fn get_name(&self) -> CName;
}

impl IsDefined for ReflectionType {
    fn is_defined(&self) -> bool {
        self.0.is_defined()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionFunc(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionFunc {
    const CLASS_NAME: &'static str = "ReflectionFunc";
    type Type = Strong;
}

#[redscript_import]
impl ReflectionFunc {
    /// `public native func GetName() -> CName`
    #[redscript(native)]
    pub fn get_name(&self) -> CName;

    /// `public native func GetFullName() -> CName`
    #[redscript(native)]
    pub fn get_full_name(&self) -> CName;

    /// `public native func GetReturnType() -> ref<ReflectionType>`
    #[redscript(native, name = "GetReturnType")]
    fn inner_get_return_type(&self) -> ReflectionType;
}

impl ReflectionFunc {
    fn get_return_type(&self) -> Option<ReflectionType> {
        let ty = self.inner_get_return_type();
        if ty.is_defined() {
            return Some(ty);
        }
        None
    }
}

impl IsDefined for ReflectionFunc {
    fn is_defined(&self) -> bool {
        self.0.is_defined()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionStaticFunc(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionStaticFunc {
    const CLASS_NAME: &'static str = "ReflectionStaticFunc";
    type Type = Strong;
}

#[redscript_import]
impl ReflectionStaticFunc {
    /// `public native func Call(opt args: array<Variant>, opt status: script_ref<Bool>) -> Variant`
    #[redscript(native)]
    pub fn call(&self, args: RedArray<Variant>, status: ScriptRef<bool>) -> Variant;
}

impl ReflectionStaticFunc {
    pub fn get_name(&self) -> CName {
        ReflectionFunc(self.0.clone()).get_name()
    }
    pub fn get_full_name(&self) -> CName {
        ReflectionFunc(self.0.clone()).get_full_name()
    }
    pub fn get_return_type(&self) -> Option<ReflectionType> {
        ReflectionFunc(self.0.clone()).get_return_type()
    }
}

impl IsDefined for ReflectionStaticFunc {
    fn is_defined(&self) -> bool {
        self.0.is_defined()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct ReflectionMemberFunc(Ref<IScriptable>);

unsafe impl RefRepr for ReflectionMemberFunc {
    const CLASS_NAME: &'static str = "ReflectionMemberFunc";
    type Type = Strong;
}

#[redscript_import]
impl ReflectionMemberFunc {
    /// `public native func Call(self: ref<IScriptable>, opt args: array<Variant>, opt status: script_ref<Bool>) -> Variant`
    #[redscript(native)]
    pub fn call(
        &self,
        this: Ref<IScriptable>,
        args: RedArray<Variant>,
        status: ScriptRef<bool>,
    ) -> Variant;
}

impl ReflectionMemberFunc {
    pub fn get_name(&self) -> CName {
        ReflectionFunc(self.0.clone()).get_name()
    }
    pub fn get_full_name(&self) -> CName {
        ReflectionFunc(self.0.clone()).get_full_name()
    }
    pub fn get_return_type(&self) -> Option<ReflectionType> {
        ReflectionFunc(self.0.clone()).get_return_type()
    }
}

impl IsDefined for ReflectionMemberFunc {
    fn is_defined(&self) -> bool {
        self.0.is_defined()
    }
}
