#![feature(arbitrary_self_types)]

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
        register_function!("Addicted.IsLosingPotency", System::is_losing_potency);

        #[cfg(debug_assertions)]
        register_function!("WriteToFile", write_to_file);
        #[cfg(debug_assertions)]
        register_function!("TestApplyStatus", test_apply_status);
        #[cfg(debug_assertions)]
        register_function!("TestRemoveStatus", test_remove_status);
        #[cfg(debug_assertions)]
        register_function!("Checkup", checkup);
    }
}

#[cfg(debug_assertions)]
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
/// Checkup(Game.GetPlayer());
/// ```
#[cfg(debug_assertions)]
fn checkup(player: WRef<cp2077_rs::PlayerPuppet>) {
    if let Some(ref player) = player.upgrade() {
        let system = &System::get_instance(player.get_game());
        let consumptions = &system.consumptions();
        let keys = consumptions.keys();
        let values = consumptions.values();
        let mut doses: Vec<f32>;
        let mut message: String;
        for (key, value) in keys.iter().zip(values.iter()) {
            doses = value.doses();
            message = format!(
                "key: {}, value.current: {}, values.doses[{}]: {}",
                key.as_ref(),
                value.current(),
                doses.len(),
                doses
                    .iter()
                    .map(f32::to_string)
                    .collect::<Vec<_>>()
                    .join(", ")
            );
            reds_dbg!("{message}");
        }
    }
}
