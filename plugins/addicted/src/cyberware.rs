use cp2077_rs::PlayerPuppet;

pub trait Cyberware {
    fn has_biomonitor(&self) -> bool;
    fn has_detoxifier(&self) -> bool;
    fn has_metabolic_editor(&self) -> bool;
}

impl Cyberware for PlayerPuppet {
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
