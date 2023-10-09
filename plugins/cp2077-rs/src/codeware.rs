use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{CName, IScriptable, Ref, ScriptRef, Variant, WRef},
};

#[derive(Debug)]
pub struct Reflection;

impl ClassType for Reflection {
    type BaseClass = IScriptable;
    const NAME: &'static str = "Reflection";
}

#[redscript_import]
impl Reflection {
    /// `public static native func GetClass(name: CName) -> ref<ReflectionClass>`
    #[redscript(native, name = "GetClass")]
    pub fn get_class(name: CName) -> WRef<ReflectionClass>;
    /// `public static native func GetTypeOf(value: Variant) -> ref<ReflectionType>`
    #[redscript(native, name = "GetTypeOf")]
    pub fn get_type_of(value: Variant) -> WRef<ReflectionType>;
    /// `public static native func GetGlobalFunction(name: CName) -> ref<ReflectionStaticFunc>`
    #[redscript(native, name = "GetGlobalFunction")]
    pub fn get_global_function(name: CName) -> WRef<ReflectionStaticFunc>;
    // `public static native func GetGlobalFunctions() -> array<ref<ReflectionStaticFunc>>`
    #[redscript(native, name = "GetGlobalFunctions")]
    pub fn get_global_functions() -> Vec<Ref<ReflectionStaticFunc>>;
}

#[derive(Debug)]
pub struct ReflectionClass;

impl ClassType for ReflectionClass {
    type BaseClass = IScriptable;
    const NAME: &'static str = "ReflectionClass";
}

#[redscript_import]
impl ReflectionClass {
    /// `public native func GetAlias() -> CName`
    #[redscript(native)]
    pub fn get_alias(self: &Ref<Self>) -> CName;

    /// `public native func GetProperty(name: CName) -> ref<ReflectionProp>`
    #[redscript(native, name = "GetProperty")]
    pub fn get_property(self: &Ref<Self>, name: CName) -> WRef<ReflectionProp>;

    /// `public native func GetStaticFunction(name: CName) -> ref<ReflectionStaticFunc>`
    #[redscript(native, name = "GetStaticFunction")]
    pub fn get_static_function(self: &Ref<Self>, name: CName) -> WRef<ReflectionStaticFunc>;

    /// `public native func GetFunction(name: CName) -> ref<ReflectionMemberFunc>`
    #[redscript(native, name = "GetFunction")]
    pub fn get_function(self: &Ref<Self>, name: CName) -> WRef<ReflectionMemberFunc>;

    /// `public native func GetStaticFunctions() -> array<ref<ReflectionStaticFunc>>`
    #[redscript(native)]
    pub fn get_static_functions(self: &Ref<Self>) -> Vec<Ref<ReflectionStaticFunc>>;

    /// `public native func GetFunctions() -> array<ref<ReflectionMemberFunc>>`
    #[redscript(native)]
    pub fn get_functions(self: &Ref<Self>) -> Vec<Ref<ReflectionMemberFunc>>;
}

#[derive(Debug)]
pub struct ReflectionProp;

impl ClassType for ReflectionProp {
    type BaseClass = IScriptable;
    const NAME: &'static str = "ReflectionProp";
}

#[redscript_import]
impl ReflectionProp {
    /// `public native func GetValue(owner: Variant) -> Variant`
    #[redscript(native)]
    pub fn get_value(self: &Ref<Self>, owner: Variant) -> Variant;

    /// `public native func SetValue(owner: Variant, value: Variant) -> Void`
    #[redscript(native)]
    pub fn set_value(self: &Ref<Self>, owner: Variant, value: Variant) -> ();
}

#[derive(Debug)]
pub struct ReflectionType;

impl ClassType for ReflectionType {
    type BaseClass = IScriptable;
    const NAME: &'static str = "ReflectionType";
}

#[redscript_import]
impl ReflectionType {
    /// `public native func GetInnerType() -> ref<ReflectionType>`
    #[redscript(native)]
    pub fn get_inner_type(self: &Ref<Self>) -> Ref<ReflectionType>;
    /// `public func AsClass() -> ref<ReflectionClass>`
    pub fn as_class(self: &Ref<Self>) -> Ref<ReflectionClass>;
    /// `public native func GetName() -> CName`
    #[redscript(native)]
    pub fn get_name(self: &Ref<Self>) -> CName;
}

#[derive(Debug)]
pub struct ReflectionFunc;

impl ClassType for ReflectionFunc {
    type BaseClass = IScriptable;
    const NAME: &'static str = "ReflectionFunc";
}

#[redscript_import]
impl ReflectionFunc {
    /// `public native func GetName() -> CName`
    #[redscript(native)]
    pub fn get_name(self: &Ref<Self>) -> CName;

    /// `public native func GetFullName() -> CName`
    #[redscript(native)]
    pub fn get_full_name(self: &Ref<Self>) -> CName;

    /// `public native func GetReturnType() -> ref<ReflectionType>`
    #[redscript(native, name = "GetReturnType")]
    fn get_return_type(self: &Ref<Self>) -> WRef<ReflectionType>;
}

#[derive(Debug)]
pub struct ReflectionStaticFunc;

impl ClassType for ReflectionStaticFunc {
    type BaseClass = ReflectionFunc;
    const NAME: &'static str = "ReflectionStaticFunc";
}

#[redscript_import]
impl ReflectionStaticFunc {
    /// `public native func Call(opt args: array<Variant>, opt status: script_ref<Bool>) -> Variant`
    #[redscript(native)]
    pub fn call(self: &Ref<Self>, args: Vec<Variant>, status: ScriptRef<bool>) -> Variant;
}

#[derive(Debug)]
pub struct ReflectionMemberFunc;

impl ClassType for ReflectionMemberFunc {
    type BaseClass = ReflectionFunc;
    const NAME: &'static str = "ReflectionMemberFunc";
}

#[redscript_import]
impl ReflectionMemberFunc {
    /// `public native func Call(self: ref<IScriptable>, opt args: array<Variant>, opt status: script_ref<Bool>) -> Variant`
    #[redscript(native)]
    pub fn call(
        self: &Ref<Self>,
        this: Ref<IScriptable>,
        args: Vec<Variant>,
        status: ScriptRef<bool>,
    ) -> Variant;
}
