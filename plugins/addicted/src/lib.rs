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
        register_function!("WriteToFile", write_to_file);
    }
}

fn write_to_file(names: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        names.join("\n"),
    );
}

fn on_process_item_action(system: System, item: ItemId) {
    system.on_process_item_action(item);
}
