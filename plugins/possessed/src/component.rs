use cp2077_rs::{IComponent, IntoTypedRef, TypedRef, GameInstance, DynamicEntitySpec};
use red4ext_rs::{
    prelude::{RefRepr, Strong},
    types::{IScriptable, Ref, EntityId},
};

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

// if GameInstance.GetSafeAreaManager(owner.GetGame()).IsPointInSafeArea(owner.GetWorldPosition()) && IsEntityInInteriorArea(EntityGameInterface.GetEntity(owner.GetEntity()))

impl GimmickComponent {
    fn on_game_attach(self) {}
    fn spawn(&mut self, spec: DynamicEntitySpec) -> EntityId {
        let mut system = GameInstance::get_dynamic_entity_system(GameInstance::default());
        system.create_entity(spec)
    }
}
