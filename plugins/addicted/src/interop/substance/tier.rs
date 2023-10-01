#[derive(Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(i64)]
#[allow(dead_code)]
pub enum Tier {
    #[default]
    One = 1,
    Two = 2,
    Three = 3,
    Four = 4,
    Five = 5,
    FivePlus = 5 + 1,
    FivePlusPlus = 5 + 1 + 1,
}
