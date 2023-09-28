use red4ext_rs::{prelude::ClassType, types::IScriptable};

#[derive(Debug)]
pub struct Event;

impl ClassType for Event {
    type BaseClass = IScriptable;
    const NAME: &'static str = "redEvent";
}
