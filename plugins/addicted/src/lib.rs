use cp2077_rs::Reflection;
use red4ext_rs::prelude::*;
use system::System;

mod addictive;
mod interop;
mod intoxication;
mod player;
mod symptoms;
mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.OnIngestedItem", System::on_ingested_item);
        register_function!("Addicted.OnStatusEffectNotAppliedOnSpawn", System::on_status_effect_not_applied_on_spawn);
        register_function!("WriteToFile", write_to_file);
        register_function!("Addicted.TestReflection", test_reflection);
    }
}

fn write_to_file(names: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        names.join("\n"),
    );
}

fn test_reflection() {
    let anchor = Reflection::default();
    let cls = anchor.get_class(CName::new("PlayerPuppet"));
    info!("reflection: {:#?}", cls.get_alias());
}
