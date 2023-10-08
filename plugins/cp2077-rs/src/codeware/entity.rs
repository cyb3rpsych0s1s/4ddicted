use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, EntityId, IScriptable, Ref, ResRef},
};

use crate::{Entity, Quaternion, Reflection, Vector4};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct DynamicEntitySystem(Ref<IScriptable>);

unsafe impl RefRepr for DynamicEntitySystem {
    const CLASS_NAME: &'static str = "DynamicEntitySystem";
    type Type = Strong;
}

#[redscript_import]
impl DynamicEntitySystem {
    /// `public native func RegisterListener(tag: CName, target: ref<IScriptable>, function: CName)`
    #[redscript(native)]
    pub fn register_listener(
        &mut self,
        tag: CName,
        target: Ref<IScriptable>,
        function: CName,
    ) -> ();
    /// `public native func UnregisterListener(tag: CName, target: ref<IScriptable>, function: CName)`
    #[redscript(native)]
    pub fn unregister_listener(
        &mut self,
        tag: CName,
        target: Ref<IScriptable>,
        function: CName,
    ) -> ();
    /// `public native func CreateEntity(spec: ref<DynamicEntitySpec>) -> EntityID`
    #[redscript(native)]
    pub fn create_entity(&mut self, spec: DynamicEntitySpec) -> EntityId;
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct DynamicEntitySpec(Ref<IScriptable>);

unsafe impl RefRepr for DynamicEntitySpec {
    const CLASS_NAME: &'static str = "DynamicEntitySpec";
    type Type = Strong;
}

impl DynamicEntitySpec {
    pub fn set_template_path(&mut self, path: ResRef) {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        cls.get_property(CName::new("templatePath"))
            .set_value(VariantExt::new(self.clone()), VariantExt::new(path));
    }
    pub fn set_position(&mut self, position: Vector4) {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        cls.get_property(CName::new("position"))
            .set_value(VariantExt::new(self.clone()), VariantExt::new(position));
    }
    pub fn set_orientation(&mut self, orientation: Quaternion) {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        cls.get_property(CName::new("orientation"))
            .set_value(VariantExt::new(self.clone()), VariantExt::new(orientation));
    }
    pub fn set_persist_state(&mut self, persist: bool) {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        cls.get_property(CName::new("persistState"))
            .set_value(VariantExt::new(self.clone()), VariantExt::new(persist));
    }
    pub fn set_persist_spawn(&mut self, persist: bool) {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        cls.get_property(CName::new("persistSpawn"))
            .set_value(VariantExt::new(self.clone()), VariantExt::new(persist));
    }
    pub fn set_tags(&mut self, tags: Vec<CName>) {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        cls.get_property(CName::new("tags"))
            .set_value(VariantExt::new(self.clone()), VariantExt::new(tags));
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct GameSessionEvent(Ref<IScriptable>);

#[redscript_import]
impl GameSessionEvent {
    /// `public native func IsRestored() -> Bool`
    #[redscript(native)]
    pub fn is_restored(&self) -> Entity;

    /// `public native func IsPreGame() -> Bool`
    #[redscript(native)]
    pub fn is_pre_game(&self) -> Entity;
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct EntityLifecycleEvent(Ref<IScriptable>);

#[redscript_import]
impl EntityLifecycleEvent {
    /// `public native func GetEntity() -> wref<Entity>`
    #[redscript(native)]
    pub fn get_entity(&self) -> Entity;
}
