use crate::interop::Threshold;

// Desensitize ?
pub trait Lessen {
    fn lessen(&self, threshold: Threshold) -> Self;
}
