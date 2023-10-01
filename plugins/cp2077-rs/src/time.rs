use std::fmt::Display;

use red4ext_rs::{
    prelude::{redscript_import, NativeRepr, RefRepr, Strong},
    types::{IScriptable, Ref},
};

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct TimeSystem(Ref<IScriptable>);

unsafe impl RefRepr for TimeSystem {
    const CLASS_NAME: &'static str = "gameTimeSystem";

    type Type = Strong;
}

#[redscript_import]
impl TimeSystem {
    /// `public native GetGameTime(): GameTime`
    #[redscript(native)]
    pub fn get_game_time(&self) -> GameTime;
    /// `public native GetGameTimeStamp(): Float`
    #[redscript(native)]
    pub fn get_game_time_stamp(&self) -> f32;
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(C)]
pub struct GameTime {
    seconds: u32,
}

unsafe impl NativeRepr for GameTime {
    const NAME: &'static str = "GameTime";
}

impl Display for GameTime {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{} day(s), {} hour(s), {} minute(s), {} second(s)",
            self.days(),
            self.hours(),
            self.minutes(),
            self.seconds()
        )
    }
}

impl From<f32> for GameTime {
    fn from(value: f32) -> Self {
        let value = value as u32;
        Self::default()
            .add_days(value / DAY)
            .add_hours(value % DAY / HOUR)
            .add_minutes(value % DAY % HOUR / MINUTE)
            .add_seconds(value % MINUTE)
    }
}

const SECOND: u32 = 1;
const MINUTE: u32 = SECOND * 60;
const HOUR: u32 = MINUTE * 60;
const DAY: u32 = HOUR * 24;

impl GameTime {
    pub fn days(&self) -> u32 {
        self.seconds / DAY
    }
    pub fn hours(&self) -> u32 {
        self.seconds % DAY / HOUR
    }
    pub fn minutes(&self) -> u32 {
        self.seconds % DAY % HOUR / MINUTE
    }
    pub fn seconds(&self) -> u32 {
        self.seconds % MINUTE
    }
    pub fn add_days(self, days: u32) -> Self {
        Self {
            seconds: self.seconds + days * DAY,
        }
    }
    pub fn add_hours(self, hours: u32) -> Self {
        Self {
            seconds: self.seconds + hours * HOUR,
        }
    }
    pub fn add_minutes(self, minutes: u32) -> Self {
        Self {
            seconds: self.seconds + minutes * MINUTE,
        }
    }
    pub fn add_seconds(self, seconds: u32) -> Self {
        Self {
            seconds: self.seconds + seconds,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{DAY, HOUR, MINUTE, SECOND};
    use crate::GameTime;

    #[test]
    fn time() {
        const DAYS: u32 = 5 * DAY;
        const HOURS: u32 = 13 * HOUR;
        const MINUTES: u32 = 50 * MINUTE;
        const SECONDS: u32 = 43 * SECOND;

        let time = GameTime {
            seconds: DAYS + HOURS + MINUTES + SECONDS,
        };
        assert_eq!(time.days(), 5);
        assert_eq!(time.hours(), 13);
        assert_eq!(time.minutes(), 50);
        assert_eq!(time.seconds(), 43);

        let time = time.add_days(2);
        assert_eq!(time.days(), 7);

        let time = time.add_seconds(17 + (9 * MINUTE));
        assert_eq!(time.days(), 7);
        assert_eq!(time.hours(), 14);
        assert_eq!(time.minutes(), 0);
        assert_eq!(time.seconds(), 0);

        let since = GameTime { seconds: 0 }
            .add_days(9)
            .add_hours(19)
            .add_minutes(12)
            .add_seconds(41);
        let now = GameTime { seconds: 0 }
            .add_days(10)
            .add_hours(4)
            .add_minutes(12)
            .add_seconds(41);
        assert_eq!(since.add_hours(9), now);
        assert!(since.add_hours(6) < now);
    }
    #[test]
    fn conversion() {
        const DAYS: u32 = 5 * DAY;
        const HOURS: u32 = 13 * HOUR;
        const MINUTES: u32 = 50 * MINUTE;
        const SECONDS: u32 = 43 * SECOND;

        let time = GameTime::from((DAYS + HOURS + MINUTES + SECONDS) as f32);
        assert_eq!(time.days(), 5);
        assert_eq!(time.hours(), 13);
        assert_eq!(time.minutes(), 50);
        assert_eq!(time.seconds(), 43);
    }
}
