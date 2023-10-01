use red4ext_rs::prelude::*;
use system::System;

mod addictive;
mod interop;
mod intoxication;
mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.OnIngestedItem", on_ingested_item);
        register_function!("Addicted.OnStatusEffectNotAppliedOnSpawn", on_status_effect_not_applied_on_spawn);
        register_function!("WriteToFile", write_to_file);
    }
}

fn write_to_file(names: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        names.join("\n"),
    );
}

fn on_ingested_item(system: System, item: ItemId) {
    system.on_ingested_item(item);
}

fn on_status_effect_not_applied_on_spawn(system: System, effect: TweakDbId) {
    system.on_status_effect_not_applied_on_spawn(effect);
}
