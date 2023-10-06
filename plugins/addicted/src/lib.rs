use red4ext_rs::prelude::*;
use system::System;

mod addictive;
mod board;
mod cyberware;
mod interop;
mod intoxication;
mod preventive;
mod symptoms;
mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.OnIngestedItem", System::on_ingested_item);
        register_function!("Addicted.OnStatusEffectNotAppliedOnSpawn", System::on_status_effect_not_applied_on_spawn);
        // register_function!("Addicted.OnEquipItem", System::on_equip_item);
        // register_function!("Addicted.OnUnequipItem", System::on_unequip_item);
        register_function!("Addicted.OnSendPaperdollUpdate", System::on_send_paperdoll_update);
        register_function!("WriteToFile", write_to_file);
    }
}

fn write_to_file(names: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        names.join("\n"),
    );
}
