use std::borrow::BorrowMut;

use crate::{on_audio_event, on_play_sound, HOOK_ON_ENT_AUDIO_EVENT, HOOK_ON_PLAY_SOUND};

/// pattern: 48 89 74 24 20 57 48 83 EC
pub(crate) const ON_ENT_AUDIO_EVENT: usize = 0x1419130;
/// pattern: 48 8B 01 FF A0 60 02 00 00
pub(crate) const ON_PLAY_SOUND: usize = 0x1696FCC;

pub(crate) type FnOnAudioEvent = unsafe extern "C" fn(usize, usize) -> ();
pub(crate) type FnOnPlaySound = unsafe extern "C" fn(usize, usize) -> ();

macro_rules! make_hook {
    ($name:ident, $address:expr, $kind:ty, $hook:expr, $storage:expr) => {
        pub(crate) fn $name() -> ::anyhow::Result<()> {
            let relative: usize = $address;
            unsafe {
                let base: usize = $crate::get_module("Cyberpunk2077.exe").unwrap() as usize;
                let address = base + relative;
                ::red4ext_rs::debug!("[{}] base address:       0x{base:X}",      ::std::stringify!{$name}); // e.g. 0x7FF6C51B0000
                ::red4ext_rs::debug!("[{}] relative address:   0x{relative:X}",  ::std::stringify!{$name}); // e.g. 0x1419130
                ::red4ext_rs::debug!("[{}] calculated address: 0x{address:X}",   ::std::stringify!{$name}); // e.g. 0x7FF6C65C9130
                let target: $kind = ::std::mem::transmute(address);
                match ::retour::RawDetour::new(target as *const (), $hook as *const ()) {
                    Ok(detour) => match detour.enable() {
                        Ok(_) => {
                            if let Ok(mut guard) = $storage.clone().borrow_mut().try_lock() {
                                *guard = Some(detour);
                            } else {
                                ::red4ext_rs::error!("could not store detour");
                            }
                        }
                        Err(e) => {
                            ::red4ext_rs::error!("could not enable detour ({e})");
                        }
                    },
                    Err(e) => {
                        ::red4ext_rs::error!("could not initialize detour ({e})");
                    }
                }
            }
            Ok(())
        }
    };
}

make_hook!(
    hook_ent_audio_event,
    ON_ENT_AUDIO_EVENT,
    FnOnAudioEvent,
    on_audio_event,
    HOOK_ON_ENT_AUDIO_EVENT
);
make_hook!(
    hook_play_sound,
    ON_PLAY_SOUND,
    FnOnPlaySound,
    on_play_sound,
    HOOK_ON_PLAY_SOUND
);
