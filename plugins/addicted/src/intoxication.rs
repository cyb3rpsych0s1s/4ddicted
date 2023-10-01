use crate::interop::Threshold;

pub trait Intoxication {
    fn threshold(&self) -> Threshold;
}

pub trait VariousIntoxication {
    fn average_threshold(&self) -> Threshold;
    fn highest_threshold(&self) -> Threshold;
}

pub trait Intoxications<T> {
    fn average_threshold(&self, by: T) -> Threshold;
    fn highest_threshold(&self, by: T) -> Threshold;
}
