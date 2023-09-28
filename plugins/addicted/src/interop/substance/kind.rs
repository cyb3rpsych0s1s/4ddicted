use red4ext_rs::prelude::NativeRepr;

#[derive(Debug, Default, Clone, Copy, PartialEq)]
#[repr(i64)]
pub enum Kind {
    #[default]
    Mild = 1,
    Hard = 2,
}

unsafe impl NativeRepr for Kind {
    const NAME: &'static str = "Addicted.Kind";
}
