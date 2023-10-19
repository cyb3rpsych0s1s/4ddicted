#![feature(arbitrary_self_types)]

use red4ext_rs::prelude::*;
use system::System;

mod addictive;
mod board;
mod cyberware;
mod interop;
mod intoxication;
mod symptoms;
mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.OnIngestedItem", System::on_ingested_item);
        register_function!("Addicted.OnStatusEffectNotAppliedOnSpawn", System::on_status_effect_not_applied_on_spawn);
        register_function!("Addicted.OnUnequipItem", System::on_unequip_item);
        register_function!("Addicted.OnProcessStatusEffect", System::on_process_status_effect);
        register_function!("Addicted.IsLosingPotency", System::is_losing_potency);
        register_function!("WriteToFile", write_to_file);
    }
}

fn write_to_file(names: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        names.join("\n"),
    );
}
