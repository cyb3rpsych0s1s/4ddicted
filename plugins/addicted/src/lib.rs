#![feature(arbitrary_self_types)]
#![feature(concat_idents)]
#![recursion_limit = "1024"]

use red4ext_rs::prelude::*;
use system::System;

mod addictive;
mod board;
mod cyberware;
mod interop;
mod intoxication;
mod lessen;
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

        #[cfg(debug_assertions)]
        register_function!("TestApplyStatus", test_apply_status);
        #[cfg(debug_assertions)]
        register_function!("TestRemoveStatus", test_remove_status);
        #[cfg(debug_assertions)]
        register_function!("SetConsumptions", set_consumptions);
    }
}

fn write_to_file(names: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        names.join("\n"),
    );
}

/// usage:
///
/// ```lua
/// TestApplyStatus(Game.GetPlayer(), "BaseStatusEffect.NotablyWeakenedBonesMcCoy70V0");
/// ```
#[cfg(debug_assertions)]
fn test_apply_status(player: WRef<cp2077_rs::PlayerPuppet>, status: String) {
    let id = if status.is_empty() {
        TweakDbId::new("BaseStatusEffect.NotablyWeakenedBonesMcCoy70V0")
    } else {
        TweakDbId::new(status.as_str())
    };
    let handle = player.upcast().upcast();
    cp2077_rs::StatusEffectHelper::apply_status_effect(handle, id, 3.);
}
/// usage:
///
/// ```lua
/// TestRemoveStatus(Game.GetPlayer(), "BaseStatusEffect.NotablyWeakenedBonesMcCoy70V0");
/// ```
#[cfg(debug_assertions)]
fn test_remove_status(player: WRef<cp2077_rs::PlayerPuppet>, status: String) {
    let id = if status.is_empty() {
        TweakDbId::new("BaseStatusEffect.NotablyWeakenedBonesMcCoy70V0")
    } else {
        TweakDbId::new(status.as_str())
    };
    let handle = player.upcast().upcast();
    cp2077_rs::StatusEffectHelper::remove_status_effect(handle, id, 1);
}
/// usage:
///
/// ```lua
/// SetConsumptions(Game.GetPlayer(), "Items.FirstAidWhiffVEpicPlus", 41);
/// ```
#[cfg(debug_assertions)]
fn set_consumptions(player: WRef<cp2077_rs::PlayerPuppet>, id: String, threshold: i32) {
    use crate::interop::Consumption;
    use interop::SubstanceId;
    if let Some(player) = player.upgrade() {
        let instance = player.get_game();
        let system = System::get_instance(instance);
        if let Ok(ref id) = SubstanceId::try_from(TweakDbId::new(id.as_str())) {
            let mut consumptions = system.consumptions();
            // call!(consumptions, "SetConsumptions;TweakDBIDInt32" (id, threshold) -> ());
            let mut keys = consumptions.keys();
            let mut values = consumptions.values();
            if let Some(position) = keys.iter().position(|x| x == id) {
                let consumption = Consumption::create(threshold);
                values[position] = consumption;
                consumptions.set_values(values);
            } else {
                let consumption = Consumption::create(threshold);
                keys.push(*id);
                values.push(consumption);
                consumptions.set_keys(keys);
                consumptions.set_values(values);
            }
        }
    }
}
