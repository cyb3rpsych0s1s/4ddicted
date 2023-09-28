use red4ext_rs::types::Ref;

use crate::interop::Threshold;

pub trait Intoxication: Sized {
    fn threshold(self: &Ref<Self>) -> Threshold
    where
        Self: Sized;
}

pub trait VariousIntoxication {
    fn average_threshold(self) -> Threshold
    where
        Self: Sized;
    fn highest_threshold(self) -> Threshold
    where
        Self: Sized;
}

pub trait Intoxications<T> {
    fn average_threshold(self: &Ref<Self>, by: T) -> Threshold
    where
        Self: Sized;
    fn highest_threshold(self: &Ref<Self>, by: T) -> Threshold
    where
        Self: Sized;
}
