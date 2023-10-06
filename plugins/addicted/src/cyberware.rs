use cp2077_rs::PlayerPuppet;
use red4ext_rs::types::{ItemId, TweakDbId};

use crate::preventive::BIOMONITOR;

pub trait SpecificCyberware {
    fn is_biomonitor(&self) -> bool;
    fn is_detoxifier(&self) -> bool;
    fn is_metabolic_editor(&self) -> bool;
}

impl SpecificCyberware for ItemId {
    fn is_biomonitor(&self) -> bool {
        BIOMONITOR.contains(&self.get_tdbid())
    }

    fn is_detoxifier(&self) -> bool {
        self.get_tdbid() == TweakDbId::new("Items.ToxinCleanser")
    }

    fn is_metabolic_editor(&self) -> bool {
        self.get_tdbid() == TweakDbId::new("Items.ReverseMetabolicEnhancer")
    }
}

pub trait ImmunityWare {
    fn has_biomonitor(&self) -> bool;
    fn has_detoxifier(&self) -> bool;
    fn has_metabolic_editor(&self) -> bool;
}

impl ImmunityWare for PlayerPuppet {
    fn has_biomonitor(&self) -> bool {
        todo!()
    }
    fn has_detoxifier(&self) -> bool {
        todo!()
    }
    fn has_metabolic_editor(&self) -> bool {
        todo!()
    }
}
