#![feature(arbitrary_self_types)]

mod board;
mod delay;
mod equipment;
mod event;
mod game;
mod housing;
mod player;
mod rpg;
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
pub use tdb::*;
pub use time::*;
pub use transaction::*;

#[cfg(feature = "codeware")]
mod codeware;
#[cfg(feature = "codeware")]
pub use codeware::*;

pub enum Error {
    Incompatible,
}
