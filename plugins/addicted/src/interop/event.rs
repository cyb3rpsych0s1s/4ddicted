use cp2077_rs::Event;
use red4ext_rs::prelude::ClassType;

#[derive(Debug)]
pub struct CrossThresholdEvent;

impl ClassType for CrossThresholdEvent {
    type BaseClass = Event;
    const NAME: &'static str = "Addicted.CrossThresholdEvent";
}
