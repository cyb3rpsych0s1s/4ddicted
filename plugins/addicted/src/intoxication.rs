use crate::interop::Threshold;

pub trait Intoxication {
    fn threshold(&self) -> Threshold;
}
