use red4ext_rs::{define_plugin, register_function};
use system::System;

mod board;
mod system;

define_plugin! {
    name: "stupefied",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Stupefied.OnConsumingItem", System::on_consuming_item);
        register_function!("Stupefied.OnStatusEffectApplied", System::on_status_effect_applied);
    }
}
