use red4ext_rs::prelude::NativeRepr;

/// addiction thresholds
///
/// V is considered as having reaching next level of addiction when crossed past a threshold.
///
/// only exception : if V score is above `Clean` but has not yet crossed `Mildly`,
/// V is considered `Barely` addicted at this point.
#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(i64)]
pub enum Threshold {
    #[default]
    Clean = 0,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
}

unsafe impl NativeRepr for Threshold {
    const NAME: &'static str = "Addicted.Threshold";
}

impl Threshold {
    pub const MIN: i32 = Self::Clean as i32;
    pub const MAX: i32 = 100;
    pub fn is_serious(self) -> bool {
        matches!(self, Self::Notably | Self::Severely)
    }
}

impl From<i32> for Threshold {
    fn from(value: i32) -> Self {
        match value as i64 {
            v if v > Self::Severely as i64 => Self::Severely,
            v if v > Self::Notably as i64 => Self::Notably,
            v if v > Self::Mildly as i64 => Self::Mildly,
            v if v >= 1 => Self::Barely,
            _ => Self::Clean,
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::interop::Threshold;

    #[test]
    fn conversion() {
        assert_eq!(Threshold::from(100), Threshold::Severely);
        assert_eq!(Threshold::from(61), Threshold::Severely);

        assert_eq!(Threshold::from(60), Threshold::Notably);
        assert_eq!(Threshold::from(41), Threshold::Notably);

        assert_eq!(Threshold::from(40), Threshold::Mildly);
        assert_eq!(Threshold::from(21), Threshold::Mildly);

        assert_eq!(Threshold::from(20), Threshold::Barely);
        assert_eq!(Threshold::from(1), Threshold::Barely);

        assert_eq!(Threshold::from(0), Threshold::Clean);
        assert_eq!(Threshold::from(-1), Threshold::Clean);
    }
}
