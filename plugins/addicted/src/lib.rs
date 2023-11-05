#![feature(arbitrary_self_types)]

use red4ext_rs::prelude::*;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        #[cfg(debug_assertions)]
        register_function!("WriteToFile", write_to_file);
        #[cfg(debug_assertions)]
        register_function!("TestApplyStatus", test_apply_status);
        #[cfg(debug_assertions)]
        register_function!("TestRemoveStatus", test_remove_status);
    }
}

#[cfg(debug_assertions)]
fn write_to_file(lines: Vec<String>, filename: String) {
    let _ = std::fs::write(
        format!("C:\\Development\\4ddicted\\{filename}.txt"),
        lines.join("\n\n"),
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

#[derive(Debug)]
pub struct BlackboardIdThreshold;
