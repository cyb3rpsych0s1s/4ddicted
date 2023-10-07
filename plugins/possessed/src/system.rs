use cp2077_rs::{EntityLifecycleEvent, GameInstance, PlayerPuppet, Downcast};
use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{CName, IScriptable, Ref, ResRef},
};

use crate::component::GimmickComponent;


#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Possessed.System";
}

#[redscript_import]
impl System {
    fn player(&self) -> PlayerPuppet;
    fn get_gimmick(&self) -> GimmickComponent;
}

impl System {
    fn as_iscriptable(&self) -> Ref<IScriptable> {
        self.0.clone()
    }
}

impl System {
    pub fn on_create_component(self) {
        let mut system = GameInstance::get_dynamic_entity_system(GameInstance::default());
        system.register_listener(
            CName::new("Entity/Assemble"),
            self.as_iscriptable(),
            CName::new("on_entity_assemble"),
        );
    }
    #[allow(dead_code)] // callback
    pub fn on_entity_assemble(&self, event: EntityLifecycleEvent) {
        let entity = event.get_entity();
        let template = entity.get_template_path();
        match template {
            v if v
                == ResRef::new("base\\characters\\entities\\player\\player_ma_fpp.ent")
                    .unwrap()
                || v == ResRef::new("base\\characters\\entities\\player\\player_fa_fpp.ent")
                    .unwrap() => {
                        if let Ok(mut player) = PlayerPuppet::try_from(entity) {
                            let gimmick = self.get_gimmick();
                            player.add_component(gimmick.downcast());
                        }
                    }
            _ => {}
        }
    }
}
