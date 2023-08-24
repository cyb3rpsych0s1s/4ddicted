use de::{Subtitle, SubtitleVariant};
use lazy_static::lazy_static;
use std::{
    borrow::BorrowMut,
    collections::HashMap,
    env::current_dir,
    path::PathBuf,
    sync::{Arc, Mutex},
};

use kira::{
    manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings},
    sound::static_sound::{StaticSoundData, StaticSoundHandle, StaticSoundSettings},
};
use red4ext_rs::{
    define_plugin, error, info,
    prelude::{redscript_global, NativeRepr},
    register_function,
    types::{CName, RedString},
    warn,
};
use retour::RawDetour;
use serde::Deserialize;
use std::ops::Not;
use widestring::U16CString;
use winapi::{shared::minwindef::HMODULE, um::libloaderapi::GetModuleHandleW};

mod de;
mod hook;

use hook::FnOnAudioEvent;

use crate::hook::FnOnPlaySound;

#[allow(non_snake_case)]
#[redscript_global(name = "DEBUG")]
fn REDS_DEBUG(message: String) -> ();

#[allow(non_snake_case)]
#[redscript_global(name = "ASSERT")]
fn REDS_ASSERT(message: String) -> ();

#[allow(non_snake_case)]
#[redscript_global(name = "SEND_AUDIO_EVENT")]
fn SEND_AUDIO_EVENT(evt: CName) -> RedString;

macro_rules! reds_debug {
    ($($args:expr),*) => {
        let args = format!("{}", format_args!($($args),*));
        $crate::REDS_DEBUG(args);
    }
}

define_plugin! {
    name: "audioware",
    author: "author",
    version: 0:1:0,
    on_register: {
        register_function!("PlayCustom", play_custom);
        register_function!("OnAttachAudioware", attach);
        register_function!("OnDetachAudioware", detach);
        register_function!("RetrieveSubtitles", retrieve_subtitles);
    }
}

#[derive(Debug, Clone, PartialEq, Deserialize)]
#[serde(rename_all = "lowercase")]
enum AudioKind {
    Sound,
    Dialog,
    Music,
    Ambient,
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, Hash, Deserialize)]
#[repr(i64)]
enum Locale {
    #[serde(rename = "en-us")]
    #[default]
    English = 0,
    #[serde(rename = "fr-fr")]
    French = 1,
}
unsafe impl NativeRepr for Locale {
    const NAME: &'static str = "Locale";
}

#[derive(Debug, Clone, PartialEq, Deserialize)]
struct Audio {
    path: String,
    kind: AudioKind,
    #[serde(skip)]
    duration: f64,
    subtitles: Option<Subtitles>,
}
impl<'a> TryFrom<&'a Selection<'a>> for StaticSoundData {
    type Error = kira::sound::FromFileError;
    fn try_from(value: &Selection) -> Result<Self, Self::Error> {
        let mut at = mods_game_dir().clone().join(value.0).join("customSounds");
        at.extend(value.1.path.split(&['\\', '/'][..]));
        info!("about to get static sound data from: {:#?}", at);
        StaticSoundData::from_file(at, StaticSoundSettings::default())
    }
}
pub struct Selection<'a>(&'a str, &'a Audio);

#[derive(Debug, Clone, PartialEq, Deserialize)]
struct Subtitles {
    id: String,
    translations: HashMap<Locale, SubtitleVariant>,
}

#[derive(Debug, Clone, Deserialize, Default)]
struct Bank(HashMap<String, Audio>);
impl Bank {
    fn get(&self, sfx: impl AsRef<str>) -> Option<&Audio> {
        self.0.get(sfx.as_ref())
    }
}

#[derive(Debug, Clone, Deserialize, Default)]
struct Banks(HashMap<String, Bank>);
impl Banks {
    fn get(&self, module: impl AsRef<str>) -> Option<&Bank> {
        self.0.get(module.as_ref())
    }
}

fn root_game_dir() -> PathBuf {
    current_dir().expect("game exists") // Cyberpunk 2077\bin\x64
}

fn mods_game_dir() -> PathBuf {
    root_game_dir()
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("mods")
}

fn setup_registry() {
    reds_debug!("setup registry...");
    let mods = std::fs::read_dir(mods_game_dir());
    reds_debug!("mods: {mods:#?}");
    if let Ok(mods) = mods {
        for rsrc in mods {
            match rsrc {
                Ok(folder) if folder.path().is_dir() => {
                    reds_debug!("found folder at: {}", folder.path().display());
                    let manifest = folder.path().join("audioware.yml");
                    let folder = folder.file_name().to_string_lossy().to_string();
                    if manifest.exists() && manifest.is_file() {
                        let raw = std::fs::read_to_string(manifest.clone()).expect("file exists");
                        let conversion = serde_yaml::from_str::<Bank>(&raw);
                        match conversion {
                            Ok(bank) => {
                                reds_debug!("{:#?}", folder);
                                let outcome = REGISTRY.clone().borrow_mut().try_lock().is_ok_and(
                                    |mut guard| guard.0.insert(folder.clone(), bank).is_none(),
                                );
                                if outcome {
                                    reds_debug!("{folder}: successful registration");
                                } else {
                                    reds_debug!("{folder}: failed registration");
                                }
                            }
                            Err(e) => {
                                error!("unable to parse manifest at: {} ({e})", manifest.display());
                            }
                        }
                    } else {
                        warn!("no manifest found in: {}", manifest.display());
                    }
                }
                Err(e) => {
                    error!("error reading files ({e})");
                }
                _ => {}
            }
        }
    }
}

lazy_static! {
    static ref AUDIO: Arc<Mutex<Audioware>> = Arc::new(Mutex::new(Audioware::default()));
    static ref REGISTRY: Arc<Mutex<Banks>> = Arc::new(Mutex::new(Banks::default()));
    static ref HANDLES: Arc<Mutex<HashMap<String, StaticSoundHandle>>> =
        Arc::new(Mutex::new(HashMap::default()));
    static ref HOOK_ON_ENT_AUDIO_EVENT: Arc<Mutex<Option<RawDetour>>> = Arc::new(Mutex::new(None));
    static ref HOOK_ON_PLAY_SOUND: Arc<Mutex<Option<RawDetour>>> = Arc::new(Mutex::new(None));
}

/// see [AudioEvent](https://github.com/WopsS/RED4ext.SDK/blob/master/include/RED4ext/Scripting/Natives/Generated/ent/AudioEvent.hpp).
#[derive(Debug, Clone)]
#[repr(C)]
pub struct AudioEvent {
    event_name: CName,
    emitter_name: CName,
    name_data: CName,
    float_data: f32,
    event_type: AudioEventActionType,
    event_flags: AudioAudioEventFlags,
}

// see [PlaySound](https://github.com/WopsS/RED4ext.SDK/blob/master/include/RED4ext/Scripting/Natives/Generated/game/audio/events/PlaySound.hpp)
#[derive(Debug, Clone)]
#[repr(C)]
pub struct PlaySound {
    sound_name: CName,
    emitter_name: CName,
    audio_tag: CName,
    seek_time: f32,
    play_unique: bool,
}

/// # Safety
/// this is only safe as long as it matches memory representation specified in [RED4ext.SDK](https://github.com/WopsS/RED4ext.SDK).
unsafe trait FromMemory {
    fn from_memory(address: usize) -> Self;
}

unsafe impl FromMemory for AudioEvent {
    fn from_memory(address: usize) -> Self {
        let event_name: CName = unsafe {
            core::slice::from_raw_parts::<CName>((address + 0x40) as *const CName, 1)
                .get_unchecked(0)
                .clone()
        };
        let emitter_name: CName = unsafe {
            core::slice::from_raw_parts::<CName>((address + 0x48) as *const CName, 1)
                .get_unchecked(0)
                .clone()
        };
        let name_data: CName = unsafe {
            core::slice::from_raw_parts::<CName>((address + 0x50) as *const CName, 1)
                .get_unchecked(0)
                .clone()
        };
        let float_data: f32 = unsafe {
            *core::slice::from_raw_parts::<f32>((address + 0x58) as *const f32, 1).get_unchecked(0)
        };
        let event_type: AudioEventActionType = unsafe {
            *core::slice::from_raw_parts::<AudioEventActionType>(
                (address + 0x5C) as *const AudioEventActionType,
                1,
            )
            .get_unchecked(0)
        };
        let event_flags: AudioAudioEventFlags = unsafe {
            *core::slice::from_raw_parts::<AudioAudioEventFlags>(
                (address + 0x60) as *const AudioAudioEventFlags,
                1,
            )
            .get_unchecked(0)
        };
        Self {
            event_name,
            emitter_name,
            name_data,
            float_data,
            event_type,
            event_flags,
        }
    }
}

unsafe impl FromMemory for PlaySound {
    fn from_memory(address: usize) -> Self {
        let sound_name: CName = unsafe {
            core::slice::from_raw_parts::<CName>((address + 0x40) as *const CName, 1)
                .get_unchecked(0)
                .clone()
        };
        let emitter_name: CName = unsafe {
            core::slice::from_raw_parts::<CName>((address + 0x48) as *const CName, 1)
                .get_unchecked(0)
                .clone()
        };
        let audio_tag: CName = unsafe {
            core::slice::from_raw_parts::<CName>((address + 0x50) as *const CName, 1)
                .get_unchecked(0)
                .clone()
        };
        let seek_time: f32 = unsafe {
            *core::slice::from_raw_parts::<f32>((address + 0x58) as *const f32, 1).get_unchecked(0)
        };
        let play_unique: bool = unsafe {
            *core::slice::from_raw_parts::<bool>((address + 0x5C) as *const bool, 1)
                .get_unchecked(0)
        };
        Self {
            sound_name,
            emitter_name,
            audio_tag,
            seek_time,
            play_unique,
        }
    }
}

#[derive(Debug, Clone, Copy, strum_macros::Display, strum_macros::FromRepr)]
#[repr(u32)]
pub enum AudioEventActionType {
    Play = 0,
    PlayAnimation = 1,
    SetParameter = 2,
    StopSound = 3,
    SetSwitch = 4,
    StopTagged = 5,
    PlayExternal = 6,
    Tag = 7,
    Untag = 8,
    SetAppearanceName = 9,
    SetEntityName = 10,
    AddContainerStreamingPrefetch = 11,
    RemoveContainerStreamingPrefetch = 12,
}

#[derive(Debug, Clone, Copy, strum_macros::Display, strum_macros::FromRepr)]
#[repr(u32)]
pub enum AudioAudioEventFlags {
    NoEventFlags = 0,
    SloMoOnly = 1,
    Music = 2,
    Unique = 4,
    Metadata = 8,
}

pub fn on_play_sound(o: usize, a: usize) {
    info!("hooked (on_play_sound)");
    if let Ok(ref guard) = HOOK_ON_PLAY_SOUND.clone().try_lock() {
        info!("hook handle retrieved (on_play_sound)");
        if let Some(detour) = guard.as_ref() {
            let PlaySound {
                sound_name,
                emitter_name,
                audio_tag,
                seek_time,
                play_unique,
            } = PlaySound::from_memory(a);
            info!(
            "got play sound: name {}, emitter {}, tag {}, seek {seek_time}, unique {play_unique}",
            red4ext_rs::ffi::resolve_cname(&sound_name),
            red4ext_rs::ffi::resolve_cname(&emitter_name),
            red4ext_rs::ffi::resolve_cname(&audio_tag)
        );

            let original: FnOnPlaySound = unsafe { std::mem::transmute(detour.trampoline()) };
            unsafe { original(o, a) };
            info!("original method called (on_play_sound)");
        }
    }
}

pub fn on_audio_event(o: usize, a: usize) {
    // info!("hooked (on_audio_event)");
    if let Ok(ref guard) = HOOK_ON_ENT_AUDIO_EVENT.clone().try_lock() {
        // info!("hook handle retrieved (on_audio_event)");
        if let Some(detour) = guard.as_ref() {
            #[allow(unused_variables)]
            let AudioEvent {
                event_name,
                emitter_name,
                name_data,
                float_data,
                event_type,
                event_flags,
            } = AudioEvent::from_memory(a);
            // info!(
            //     "got audio event: name {}, emitter {}, data {}, float {float_data}, type {event_type}, flags {event_flags}",
            //     red4ext_rs::ffi::resolve_cname(&event_name),
            //     red4ext_rs::ffi::resolve_cname(&emitter_name),
            //     red4ext_rs::ffi::resolve_cname(&name_data)
            // );

            let original: FnOnAudioEvent = unsafe { std::mem::transmute(detour.trampoline()) };
            unsafe { original(o, a) };
            // info!("original method called");
        }
    }
}

pub fn attach() {
    info!("on attach audioware");
    let _ = hook::hook_ent_audio_event();
    let _ = hook::hook_play_sound();
    let manager = AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap();
    *AUDIO.clone().borrow_mut().lock().unwrap() = Audioware(Some(manager));
    setup_registry();
    info!(
        "initialized audioware (thread: {:#?})",
        std::thread::current().id()
    );
}
pub fn detach() {
    info!("on detach audioware");
    *AUDIO.clone().borrow_mut().lock().unwrap() = Audioware(None);
    *REGISTRY.clone().borrow_mut().lock().unwrap() = Banks::default();
    *HANDLES.clone().borrow_mut().lock().unwrap() = HashMap::default();
    *HOOK_ON_ENT_AUDIO_EVENT.clone().borrow_mut().lock().unwrap() = None;
    *HOOK_ON_PLAY_SOUND.clone().borrow_mut().lock().unwrap() = None;
    info!(
        "cleaned audioware (thread: {:#?})",
        std::thread::current().id()
    );
}

#[derive(Default)]
pub struct Audioware(Option<AudioManager<DefaultBackend>>);

impl Audioware {
    fn play_custom(&mut self, module: impl AsRef<str>, id: impl AsRef<str>) -> bool {
        info!("play custom (thread: {:#?})", std::thread::current().id());
        if let Some(ref mut manager) = self.0 {
            info!("audio manager about to play...");
            if let Ok(ref guard) = REGISTRY.clone().try_lock() {
                let banks = guard.clone();
                if let Some(bank) = banks.get(module.as_ref()) {
                    if let Some(audio) = bank.get(id.as_ref()) {
                        if let Ok(data) =
                            StaticSoundData::try_from(&Selection(module.as_ref(), audio))
                        {
                            info!("retrieved static sound data {:#?}", data);
                            if let Ok(handle) = manager.play(data) {
                                if let Ok(ref mut guard) = HANDLES.clone().borrow_mut().try_lock() {
                                    if !guard.contains_key(id.as_ref()) {
                                        return guard
                                            .insert(id.as_ref().to_string(), handle)
                                            .is_none();
                                    }
                                    return true;
                                } else {
                                    warn!("unable to get HANDLES");
                                }
                            } else {
                                warn!("unable to play static sound data from: {}", audio.path);
                            }
                        } else {
                            warn!("unable to get static sound data from: {}", audio.path);
                        }
                    } else {
                        warn!("unknown sfx {}", id.as_ref());
                    }
                } else {
                    warn!("unknown bank {}", module.as_ref());
                }
            }
        } else {
            warn!("for some reason there's no manager when there should be");
        }
        false
    }
}

fn play_custom(module: String, sfx: String) -> bool {
    info!(
        "getting audio manager handle... (thread: {:#?})",
        std::thread::current().id()
    );
    if let Ok(mut guard) = (*AUDIO.clone().borrow_mut()).lock() {
        info!(
            "audio manager handle exists (thread: {:#?})",
            std::thread::current().id()
        );
        let outcome = guard.play_custom(module, sfx);
        info!(
            "audio manager finished playing! (outcome: {outcome}, thread: {:#?})",
            std::thread::current().id()
        );
        return outcome;
    }
    false
}

#[repr(C)]
pub struct Translation {
    locale: Locale,
    female: RedString,
    male: RedString,
}

unsafe impl NativeRepr for Translation {
    // this needs to refer to an actual in-game type name
    const NAME: &'static str = "Translation";
}

fn retrieve_subtitles(module: String, locale: Locale) -> Vec<Translation> {
    info!("retrieve subtitles from Rust");
    let mut translations = Vec::<Translation>::new();
    if let Ok(ref guard) = REGISTRY.clone().try_lock() {
        let banks = guard.clone();
        if let Some(bank) = banks.get(module.as_str()) {
            let keys = bank.0.keys();
            info!("keys {keys:#?}");
            for key in keys {
                if let Some(subtitles) = &bank.0.get(key).unwrap().subtitles {
                    if let Some(translation) = subtitles.translations.get(&locale) {
                        info!("found translation for {key}:{locale:#?}:{translation:#?}");
                        let translation = match translation {
                            SubtitleVariant::Neutral(translation) => Translation {
                                locale,
                                female: RedString::new(translation.as_str()),
                                male: RedString::new(translation.as_str()),
                            },
                            SubtitleVariant::Sensitive(Subtitle { female, male }) => Translation {
                                locale,
                                female: RedString::new(female.as_str()),
                                male: RedString::new(male.as_str()),
                            },
                        };
                        translations.push(translation);
                    }
                }
            }
        }
    }
    info!("looped subtitles");
    translations
}

unsafe fn get_module(module: &str) -> Option<HMODULE> {
    let module = U16CString::from_str_truncate(module);
    let res = GetModuleHandleW(module.as_ptr());
    res.is_null().not().then_some(res)
}
