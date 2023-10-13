use cp2077_rs::{BlackboardIdUint, PlayerStateMachineDef, Reflection};
use red4ext_rs::types::CName;
use red4ext_rs::types::VariantExt;
use red4ext_rs::types::{Ref, Variant};
use red4ext_rs::conv::ClassType;

pub trait AddictedBoard {
    fn withdrawal_symptoms(self: &Ref<Self>) -> BlackboardIdUint
    where
        Self: Sized;
}

impl AddictedBoard for PlayerStateMachineDef {
    fn withdrawal_symptoms(self: &Ref<Self>) -> BlackboardIdUint
    where
        Self: Sized,
    {
        let cls = Reflection::get_class(CName::new(Self::NAME))
            .into_ref()
            .expect("get class PlayerStateMachineDef");
        let field = cls
            .get_property(CName::new("WithdrawalSymptoms"))
            .into_ref()
            .expect("get prop WithdrawalSymptoms for class PlayerStateMachineDef");
        field
            .get_value(Variant::new(self.clone()))
            .try_take()
            .expect("value for prop WithdrawalSymptoms of type BlackboardID_Uint")
    }
}
