use cp2077_rs::{BlackboardIdBool, PlayerStateMachineDef, Reflection};
use red4ext_rs::conv::RefRepr;
use red4ext_rs::types::CName;

pub trait StupefiedBoard {
    fn is_consuming(&self) -> BlackboardIdBool;
}

impl StupefiedBoard for PlayerStateMachineDef {
    fn is_consuming(&self) -> BlackboardIdBool {
        use red4ext_rs::types::VariantExt;
        let reflection = Reflection::default();
        let cls = reflection.get_class(CName::new(Self::CLASS_NAME)).unwrap();
        let field = cls.get_property(CName::new("IsConsuming")).unwrap();
        VariantExt::try_get(&field.get_value(VariantExt::new(self.clone())))
            .expect("prop IsConsuming of type BlackboardID_Bool")
    }
}
