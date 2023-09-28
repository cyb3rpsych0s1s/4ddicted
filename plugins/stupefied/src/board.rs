use cp2077_rs::Reflection;
use cp2077_rs::{BlackboardIdBool, PlayerStateMachineDef};
use red4ext_rs::conv::ClassType;
use red4ext_rs::types::CName;
use red4ext_rs::types::VariantExt;
use red4ext_rs::types::{Ref, Variant};

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
        let cls = Reflection::get_class(CName::new(Self::NAME))
            .into_ref()
            .expect("get class PlayerStateMachineDef");
        let field = cls
            .get_property(CName::new("IsConsuming"))
            .into_ref()
            .expect("get prop IsConsuming on class PlayerStateMachineDef");
        field
            .get_value(Variant::new(self.clone()))
            .try_take()
            .expect("value for prop IsConsuming of type BlackboardID_Bool")
    }
}
