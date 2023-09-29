use red4ext_rs::prelude::*;
use red4ext_rs::types::{IScriptable, Ref};

use crate::interop::SubstanceId;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct System(Ref<IScriptable>);

unsafe impl RefRepr for System {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.System";
}

impl System {
    pub fn on_ingested_item(&self, item: ItemId) {
        info!("consuming {item:#?}");
        if let Some(_) = SubstanceId::try_from(item).ok() {
            info!("item is addictive");
        }
    }
}
