use cp2077_rs::{BlackboardIdUint, PlayerStateMachineDef, Reflection};
use red4ext_rs::types::{CName, Ref};

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
        use red4ext_rs::conv::ClassType;
        use red4ext_rs::types::VariantExt;
        let cls = Reflection::get_class(CName::new(Self::NAME))
            .upgrade()
            .expect("get class PlayerStateMachineDef");
        let field = cls
            .get_property(CName::new("WithdrawalSymptoms"))
            .upgrade()
            .expect("get prop WithdrawalSymptoms for class PlayerStateMachineDef");
        VariantExt::try_take(
            &mut field.get_value(VariantExt::new(red4ext_rs::prelude::Ref::<
                PlayerStateMachineDef,
            >::downgrade(&self))),
        )
        .expect("prop WithdrawalSymptoms of type BlackboardID_Uint")
    }
}
