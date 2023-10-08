use red4ext_rs::{define_plugin, register_function};

mod component;
mod system;

use system::System;

define_plugin! {
    name: "possessed",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Possessed.OnIngestedItem", System::on_create_component);
    }
}
