#![feature(arbitrary_self_types)]

use red4ext_rs::{define_plugin, register_function};

mod board;
mod system;

use system::CompanionSystem;

define_plugin! {
    name: "stupefied",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Stupefied.OnConsumingItem", CompanionSystem::on_consuming_item);
        register_function!("Stupefied.OnConsumedItem", CompanionSystem::on_consumed_item);
    }
}
