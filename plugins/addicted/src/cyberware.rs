use cp2077_rs::PlayerPuppet;
use red4ext_rs::types::ItemId;

pub trait SpecificCyberware {
    fn is_biomonitor(&self) -> bool;
    fn is_detoxifier(&self) -> bool;
    fn is_metabolic_editor(&self) -> bool;
}

impl SpecificCyberware for ItemId {
    fn is_biomonitor(&self) -> bool {
        todo!()
    }

    fn is_detoxifier(&self) -> bool {
        todo!()
    }

    fn is_metabolic_editor(&self) -> bool {
        todo!()
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
