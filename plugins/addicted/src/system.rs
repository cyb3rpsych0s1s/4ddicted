use cp2077_rs::Housing;
use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::interop::{Consumption, Consumptions, SubstanceId};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.System";
}

#[redscript_import]
impl System {
    fn consumptions(&self) -> Consumptions;
}

impl System {
    pub fn on_ingested_item(&self, item: ItemId) {
        info!("consuming {item:#?}");
        if let Some(id) = SubstanceId::try_from(item).ok() {
            info!("item is addictive");
            let consumption = self
                .consumptions()
                .get(id.clone())
                .map(|mut existing| {
                    existing.current += 1;
                    // TODO doses ...
                    existing
                })
                .unwrap_or(Consumption::new(1));
            self.consumptions().set(id, consumption);
        }
    }
    pub fn on_status_effect_not_applied_on_spawn(&self, effect: TweakDbId) {
        if effect.is_housing() {
            info!("housing: {effect:#?}");
        }
    }
}
