use crate::interop::Threshold;

pub trait Addiction {
    fn threshold(&self) -> Threshold;
}
