mod interop;
mod plugin;
mod utils;

use interop::{Banks, Locale, Translation};
use lazy_static::lazy_static;
use plugin::Audioware;
use std::{
    borrow::BorrowMut,
    collections::HashMap,
    env::current_dir,
    path::PathBuf,
    sync::{Arc, Mutex},
};

use kira::{
    manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings},
    sound::static_sound::StaticSoundHandle,
};
use red4ext_rs::{define_plugin, error, info, register_function, warn};

use crate::interop::Bank;

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
                                    |mut guard| guard.insert(folder.clone(), bank).is_none(),
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
}

pub fn attach() {
    info!("on attach audioware");
    let manager = AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap();
    let _ = Audioware::create(manager);
    setup_registry();
    info!(
        "initialized audioware (thread: {:#?})",
        std::thread::current().id()
    );
}
pub fn detach() {
    info!("on detach audioware");
    let _ = Audioware::clear();
    *REGISTRY.clone().borrow_mut().lock().unwrap() = Banks::default();
    *HANDLES.clone().borrow_mut().lock().unwrap() = HashMap::default();
    info!(
        "cleaned audioware (thread: {:#?})",
        std::thread::current().id()
    );
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

fn retrieve_subtitles(module: String, locale: Locale) -> Vec<Translation> {
    info!("retrieve subtitles from Rust");
    let mut translations = Vec::<Translation>::new();
    if let Ok(ref guard) = REGISTRY.clone().try_lock() {
        let banks = guard.clone();
        if let Some(bank) = banks.get(module.as_str()) {
            let keys = bank.keys();
            info!("keys {keys:#?}");
            for key in keys {
                if let Some(subtitles) = &bank.get(key).unwrap().subtitles() {
                    if let Some(translation) = subtitles.translations().get(&locale) {
                        info!("found translation for {key}:{locale:#?}:{translation:#?}");
                        let translation = (locale, translation).into();
                        translations.push(translation);
                    }
                }
            }
        }
    }
    info!("looped subtitles");
    translations
}
