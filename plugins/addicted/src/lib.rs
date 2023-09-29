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
        register_function!("Addicted.OnProcessItemAction", on_process_item_action);
    }
}

fn on_process_item_action(system: System, item: ItemId) {
    system.on_process_item_action(item);
}
