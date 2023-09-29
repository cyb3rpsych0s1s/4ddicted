use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, RedArray, Ref},
};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumption(Ref<IScriptable>);

unsafe impl RefRepr for Consumption {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.Consumption";
}

#[redscript_import]
impl Consumption {
    pub fn set_current(&self, v: i32) -> ();
    pub fn get_current(&self) -> i32;
    pub fn set_doses(&self, v: RedArray<f32>) -> ();
    pub fn get_doses(&self) -> Vec<f32>;
}
