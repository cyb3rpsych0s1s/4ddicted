use red4ext_rs::prelude::*;
use system::System;

mod addictive;
mod interop;
mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.PluginOnConsumeItem", on_consume_item);
    }
}

fn on_consume_item(system: System, item: ItemId) {
    system.on_consume_item(item);
}
