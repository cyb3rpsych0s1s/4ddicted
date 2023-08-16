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
use red4ext_rs::{define_plugin, error, info, prelude::redscript_global, register_function, warn};
use serde::{Deserialize, Serialize};

#[redscript_global(name = "RemoteLogChannel")]
fn remote_log(message: String) -> ();

macro_rules! remote_info {
    ($($args:expr),*) => {
        let args = format!("[audioware][info] {}", format_args!($($args),*));
        remote_log(args);
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
    }
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
enum AudioKind {
    Sound,
    Dialog,
    Music,
    Ambient,
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct Audio {
    path: String,
    kind: AudioKind,
    #[serde(skip)]
    duration: f64,
}
impl From<&Audio> for StaticSoundData {
    fn from(value: &Audio) -> Self {
        StaticSoundData::from_file(value.path.clone(), StaticSoundSettings::default())
            .expect("previously validated path")
    }
}

#[derive(Default, Serialize, Deserialize, derive_more::Deref, derive_more::DerefMut)]
struct Bank(HashMap<String, Audio>);
impl Bank {
    fn get(&self, sfx: impl AsRef<str>) -> Option<&Audio> {
        self.0.get(sfx.as_ref())
    }
}

#[derive(Default, Serialize, Deserialize, derive_more::Deref, derive_more::DerefMut)]
struct Banks(HashMap<String, Bank>);
impl Banks {
    fn get(&self, module: impl AsRef<str>) -> Option<&Bank> {
        self.0.get(module.as_ref())
    }
}

fn setup_registry() {
    remote_info!("setup registry...");
    let current = current_dir().unwrap(); // Cyberpunk 2077\bin\x64
    info!("current dir is: {current:#?}");
    let mods = current.join("..").join("..").join("mods");
    let mods = std::fs::read_dir(mods);
    if let Ok(mods) = mods {
        for resource in mods {
            if let Ok(resource) = resource {
                if resource.path().is_dir() {
                    let manifest = PathBuf::from(resource.path()).join("audioware.yml");
                    if manifest.exists() && manifest.is_file() {
                        let conversion =
                            serde_yaml::from_str::<Bank>(manifest.to_str().expect("file exists"));
                        match conversion {
                            Ok(bank) => {
                                if let Ok(ref mut guard) = REGISTRY.clone().borrow_mut().lock() {
                                    guard.insert(
                                        resource.file_name().to_string_lossy().to_string(),
                                        bank,
                                    );
                                } else {
                                    error!(
                                        "unable to register manifest at: {}",
                                        manifest.display()
                                    );
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
    info!("[red4ext] on attach audioware");
    let manager = AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap();
    *AUDIO.clone().borrow_mut().lock().unwrap() = Audioware(Some(manager));
    setup_registry();
    info!(
        "[red4ext] initialized audioware (thread: {:#?})",
        std::thread::current().id()
    );
}
pub fn detach() {
    info!("[red4ext] on detach audioware");
    *AUDIO.clone().borrow_mut().lock().unwrap() = Audioware(None);
    *REGISTRY.clone().borrow_mut().lock().unwrap() = Banks::default();
    *HANDLES.clone().borrow_mut().lock().unwrap() = HashMap::default();
    info!(
        "[red4ext] cleaned audioware (thread: {:#?})",
        std::thread::current().id()
    );
}

pub struct Audioware(Option<AudioManager<DefaultBackend>>);
impl Default for Audioware {
    fn default() -> Self {
        Self(None)
    }
}
impl Audioware {
    fn play_custom(&mut self, module: impl AsRef<str>, id: impl AsRef<str>) -> bool {
        info!(
            "[red4ext] play custom (thread: {:#?})",
            std::thread::current().id()
        );
        if let Some(ref mut manager) = self.0 {
            info!("[red4ext] audio manager about to play...");
            if let Ok(ref guard) = REGISTRY.clone().lock() {
                let banks = guard.clone();
                if let Some(bank) = banks.get(module.as_ref()) {
                    if let Some(sfx) = bank.get(id.as_ref()) {
                        let handle = manager.play(StaticSoundData::from(sfx)).unwrap();
                        if let Ok(ref mut guard) = HANDLES.clone().borrow_mut().lock() {
                            guard.insert(id.as_ref().to_string(), handle);
                            return true;
                        }
                    }
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
        "[red4ext] getting audio manager handle... (thread: {:#?})",
        std::thread::current().id()
    );
    info!(
        "[red4ext] audio manager handle exists (thread: {:#?})",
        std::thread::current().id()
    );
    if let Ok(mut guard) = (*AUDIO.clone().borrow_mut()).lock() {
        let outcome = guard.play_custom(module, sfx);
        info!(
            "[red4ext] audio manager finished playing! (thread: {:#?})",
            std::thread::current().id()
        );
        return outcome;
    }
    false
}
