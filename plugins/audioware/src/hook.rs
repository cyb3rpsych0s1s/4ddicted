use std::{
    borrow::BorrowMut,
    sync::{Arc, Mutex},
};

use lazy_static::lazy_static;
use retour::RawDetour;

use crate::{
    interop::{AudioEvent, PlaySound, SoundEvent},
    FromMemory,
};

pub(crate) struct Hooks;
impl Hooks {
    pub fn on_attach() {
        let _ = hook_ent_audio_event();
        let _ = hook_play_sound();
        let _ = hook_ent_sound_event();
    }
    pub fn on_detach() {
        let _ = HOOK_ON_ENT_AUDIO_EVENT
            .clone()
            .borrow_mut()
            .lock()
            .unwrap()
            .take();
        let _ = HOOK_ON_GAMEAUDIOEVENTS_PLAY_SOUND
            .clone()
            .borrow_mut()
            .lock()
            .unwrap()
            .take();
        let _ = HOOK_ON_ENT_SOUND_EVENT
            .clone()
            .borrow_mut()
            .lock()
            .unwrap()
            .take();
    }
}

/// pattern: `48 89 74 24 20 57 48 83  EC`
pub(crate) const ON_ENT_AUDIO_EVENT: usize = 0x1419130;
/// pattern: `48 8B 01 FF A0 60 02 00  00`
pub(crate) const ON_GAMEAUDIOEVENTS_PLAY_SOUND: usize = 0x1696FCC;
/// pattern: `48 89 6C 24 20 56 48 81  EC`
pub(crate) const ON_ENT_DISMEMBERMENT_AUDIO_EVENT: usize = 0x169FAD0;
/// pattern: `40 56 48 83 EC 20 48 8B  81`
pub(crate) const ON_ENT_DESTRUCTION_AUDIO_EVENT: usize = 0x199D6C0;
/// pattern: `48 8B 89 80 05 00 00 E9  54`
pub(crate) const ON_VEHICLE_AUDIO_EVENT: usize = 0x1C93E80;
/// pattern: `48 8B 89 80 05 00 00 48  85`
pub(crate) const ON_VEHICLE_VEHICLE_AUDIO_MULTIPLIERS_EVENT: usize = 0x1C96C00;
/// pattern: `48 8B 49 58 48 85 C9 74  09`
pub(crate) const ON_ENT_SOUND_EVENT: usize = 0x1695CB0;
/// pattern: `CF 3C 01 E9 20 FF FF FF  48`
pub(crate) const ON_GAMEAUDIOEVENTS_SOUND_PARAMETER: usize = 0x16D6088;
/// pattern: `A0 60 02 00 00 CC CC CC  48`
pub(crate) const ON_GAMEAUDIOEVENTS_SOUND_SWITCH: usize = 0x1696FD8;
/// pattern: `A0 60 02 00 00 CC CC CC  48`
pub(crate) const ON_GAMEAUDIOEVENTS_STOP_SOUND: usize = 0x1696FD8;
/// pattern: `00 CC CC CC 48 8B 01 FF  A0`
pub(crate) const ON_GAMEAUDIOEVENTS_STOP_TAGGED_SOUNDS: usize = 0x1696FE4;
/// pattern: `C6 41 71 01 C3 CC CC CC  CC`
pub(crate) const ON_GAMEAUDIOEVENTS_DIALOG_LINE: usize = 0x1695CD0;
/// pattern: `40 57 48 83 EC 50 48 83  B9`
pub(crate) const ON_GAMEAUDIOEVENTS_MUSIC_EVENT: usize = 0x199DC50;
/// pattern: `C6 41 71 00 C3 CC CC CC  CC`
pub(crate) const ON_GAMEAUDIOEVENTS_STOP_DIALOG_LINE: usize = 0x1027B80;
/// pattern: `40 55 53 56 41 56 48 8D  6C`
pub(crate) const ON_GAMEAUDIOEVENTS_VOICE_EVENT: usize = 0x199E290;
/// pattern: `80 7A 4C 00 75 08 8B 52  48`
pub(crate) const ON_GAMEAUDIOEVENTS_VOICE_PLAYED_EVENT: usize = 0x234F820;

pub(crate) type ExternFnRedEventHandler = unsafe extern "C" fn(usize, usize) -> ();

lazy_static! {
    pub(crate) static ref HOOK_ON_ENT_AUDIO_EVENT: Arc<Mutex<Option<RawDetour>>> =
        Arc::new(Mutex::new(None));
    pub(crate) static ref HOOK_ON_GAMEAUDIOEVENTS_PLAY_SOUND: Arc<Mutex<Option<RawDetour>>> =
        Arc::new(Mutex::new(None));
    pub(crate) static ref HOOK_ON_ENT_SOUND_EVENT: Arc<Mutex<Option<RawDetour>>> =
        Arc::new(Mutex::new(None));
}

macro_rules! make_hook {
    ($name:ident, $address:expr, $kind:ty, $hook:expr, $storage:expr) => {
        pub(crate) fn $name() -> ::anyhow::Result<()> {
            let relative: usize = $address;
            unsafe {
                let base: usize = $crate::get_module("Cyberpunk2077.exe").unwrap() as usize;
                let address = base + relative;
                ::red4ext_rs::debug!(
                    "[{}] base address:       0x{base:X}",
                    ::std::stringify! {$name}
                ); // e.g. 0x7FF6C51B0000
                ::red4ext_rs::debug!(
                    "[{}] relative address:   0x{relative:X}",
                    ::std::stringify! {$name}
                ); // e.g. 0x1419130
                ::red4ext_rs::debug!(
                    "[{}] calculated address: 0x{address:X}",
                    ::std::stringify! {$name}
                ); // e.g. 0x7FF6C65C9130
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
    ExternFnRedEventHandler,
    on_audio_event,
    HOOK_ON_ENT_AUDIO_EVENT
);
make_hook!(
    hook_play_sound,
    ON_GAMEAUDIOEVENTS_PLAY_SOUND,
    ExternFnRedEventHandler,
    on_play_sound,
    HOOK_ON_GAMEAUDIOEVENTS_PLAY_SOUND
);
make_hook!(
    hook_ent_sound_event,
    ON_ENT_SOUND_EVENT,
    ExternFnRedEventHandler,
    on_ent_sound_event,
    HOOK_ON_ENT_SOUND_EVENT
);

pub fn on_play_sound(o: usize, a: usize) {
    red4ext_rs::trace!("[on_play_sound] hooked");
    if let Ok(ref guard) = HOOK_ON_GAMEAUDIOEVENTS_PLAY_SOUND.clone().try_lock() {
        red4ext_rs::trace!("[on_play_sound] hook handle retrieved");
        if let Some(detour) = guard.as_ref() {
            let PlaySound {
                sound_name,
                emitter_name,
                audio_tag,
                seek_time,
                play_unique,
            } = PlaySound::from_memory(a);
            red4ext_rs::info!(
            "[on_play_sound][PlaySound] name {}, emitter {}, tag {}, seek {seek_time}, unique {play_unique}",
            red4ext_rs::ffi::resolve_cname(&sound_name),
            red4ext_rs::ffi::resolve_cname(&emitter_name),
            red4ext_rs::ffi::resolve_cname(&audio_tag)
        );

            let original: ExternFnRedEventHandler =
                unsafe { std::mem::transmute(detour.trampoline()) };
            unsafe { original(o, a) };
            red4ext_rs::trace!("[on_play_sound] original method called");
        }
    }
}

pub fn on_audio_event(o: usize, a: usize) {
    red4ext_rs::trace!("[on_audio_event] hooked");
    if let Ok(ref guard) = HOOK_ON_ENT_AUDIO_EVENT.clone().try_lock() {
        red4ext_rs::trace!("[on_audio_event] hook handle retrieved");
        if let Some(detour) = guard.as_ref() {
            let AudioEvent {
                event_name,
                emitter_name,
                name_data,
                float_data,
                event_type,
                event_flags,
            } = AudioEvent::from_memory(a);
            red4ext_rs::info!(
                "[on_audio_event][AudioEvent] name {}, emitter {}, data {}, float {float_data}, type {event_type}, flags {event_flags}",
                red4ext_rs::ffi::resolve_cname(&event_name),
                red4ext_rs::ffi::resolve_cname(&emitter_name),
                red4ext_rs::ffi::resolve_cname(&name_data)
            );

            let original: ExternFnRedEventHandler =
                unsafe { std::mem::transmute(detour.trampoline()) };
            unsafe { original(o, a) };
            red4ext_rs::trace!("[on_audio_event] original method called");
        }
    }
}

pub fn on_ent_sound_event(gameobject_ptr: usize, evt_ptr: usize) {
    red4ext_rs::trace!("[on_ent_sound_event] hooked");
    if let Ok(ref guard) = HOOK_ON_ENT_AUDIO_EVENT.clone().try_lock() {
        red4ext_rs::trace!("[on_ent_sound_event] hook handle retrieved");
        if let Some(detour) = guard.as_ref() {
            let SoundEvent { event_name } = SoundEvent::from_memory(evt_ptr);
            red4ext_rs::info!(
                "[on_ent_sound_event][SoundEvent] name {}",
                red4ext_rs::ffi::resolve_cname(&event_name)
            );

            let original: ExternFnRedEventHandler =
                unsafe { std::mem::transmute(detour.trampoline()) };
            unsafe { original(gameobject_ptr, evt_ptr) };
            red4ext_rs::trace!("[on_ent_sound_event] original method called");
        }
    }
}
