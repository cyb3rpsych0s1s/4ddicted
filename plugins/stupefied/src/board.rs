use cp2077_rs::{BlackboardIdBool, PlayerStateMachineDef, Reflection};
use red4ext_rs::types::{CName, Ref};

pub trait StupefiedBoard {
    fn is_consuming(self: &Ref<Self>) -> BlackboardIdBool
    where
        Self: Sized;
}

impl StupefiedBoard for PlayerStateMachineDef {
    fn is_consuming(self: &Ref<Self>) -> BlackboardIdBool
    where
        Self: Sized,
    {
        use red4ext_rs::conv::ClassType;
        use red4ext_rs::types::VariantExt;
        let cls = Reflection::get_class(CName::new(Self::NAME))
            .into_ref()
            .expect("get class PlayerStateMachineDef");
        let field = cls
            .get_property(CName::new("IsConsuming"))
            .into_ref()
            .expect("get prop IsConsuming on class PlayerStateMachineDef");
        VariantExt::try_take(
            &mut field.get_value(VariantExt::new(red4ext_rs::prelude::Ref::<
                PlayerStateMachineDef,
            >::downgrade(&self))),
        )
        .expect("prop IsConsuming of type BlackboardID_Bool")
    }
}
