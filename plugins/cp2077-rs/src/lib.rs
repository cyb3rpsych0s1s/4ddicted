#![feature(arbitrary_self_types)]

mod board;
mod delay;
mod equipment;
mod event;
mod game;
mod housing;
mod player;
mod rpg;
mod status;
mod tdb;
mod time;
mod transaction;

pub use board::*;
pub use delay::*;
pub use equipment::*;
pub use event::*;
pub use game::*;
pub use housing::*;
pub use player::*;
pub use rpg::*;
pub use status::*;
pub use tdb::*;
pub use time::*;
pub use transaction::*;

#[cfg(feature = "codeware")]
mod codeware;
#[cfg(feature = "codeware")]
pub use codeware::*;

#[derive(Debug)]
pub enum Error {
    Incompatible,
}

#[cfg(debug_assertions)]
#[red4ext_rs::prelude::redscript_global(name = "LogChannel", native)]
fn native_log(
    channel: red4ext_rs::types::CName,
    message: red4ext_rs::types::ScriptRef<red4ext_rs::types::RedString>,
) -> ();

#[cfg(debug_assertions)]
#[macro_export]
macro_rules! reds_dbg {
    ($($arg:tt)*) => {
        #[cfg(not(feature = "console"))]
        ::red4ext_rs::prelude::info!($($arg)*);
        #[cfg(feature = "console")]
        $crate::native_log(
            CName::new("DEBUG"),
            ScriptRef::new(&mut RedString::new(::std::format!($($arg)*))),
        );
    };
}
