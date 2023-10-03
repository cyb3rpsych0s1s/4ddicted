use cp2077_rs::{BlackboardIdUint, PlayerStateMachineDef, Reflection};
use red4ext_rs::conv::RefRepr;
use red4ext_rs::types::CName;

pub trait CustomBoard {
    fn withdrawal_symptoms(&self) -> BlackboardIdUint;
}

impl CustomBoard for PlayerStateMachineDef {
    fn withdrawal_symptoms(&self) -> BlackboardIdUint {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME));
        let field = cls.get_property(CName::new("WithdrawalSymptoms"));
        VariantExt::try_get(&field.get_value(VariantExt::new(self.clone())))
            .expect("prop WithdrawalSymptoms of type BlackboardID_Uint")
    }
}
