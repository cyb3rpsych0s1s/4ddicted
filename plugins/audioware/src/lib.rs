use std::{
    borrow::BorrowMut,
    collections::HashMap,
    env::current_dir,
    sync::{Arc, Mutex},
};

use lazy_static::lazy_static;

use kira::{
    manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings},
    sound::static_sound::{StaticSoundData, StaticSoundHandle, StaticSoundSettings},
};
use red4ext_rs::{define_plugin, info, register_function, warn};

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

const ID: &str = "NahImCool";

lazy_static! {
    static ref AUDIO: Arc<Mutex<Audioware>> = Arc::new(Mutex::new(Audioware::default()));
    static ref REGISTRY: Arc<Mutex<HashMap<String, StaticSoundData>>> =
        Arc::new(Mutex::new(HashMap::default()));
    static ref HANDLES: Arc<Mutex<HashMap<String, StaticSoundHandle>>> =
        Arc::new(Mutex::new(HashMap::default()));
}

pub fn attach() {
    info!("[red4ext] on attach audioware");
    let manager = AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap();
    *AUDIO.clone().borrow_mut().lock().unwrap() = Audioware(Some(manager));
    let current = current_dir().unwrap(); // Cyberpunk 2077\bin\x64
    info!("current dir is: {current:#?}");
    let filepath = current
        .join("..")
        .join("..")
        .join("mods")
        .join("Addicted")
        .join("customSounds")
        .join("en-us")
        .join("offhanded")
        .join("fem_v_nic_v7VBWSUGf9Erb9upBsY2.wav");
    if let Ok(ref mut guard) = REGISTRY.clone().borrow_mut().lock() {
        let sound = StaticSoundData::from_file(filepath, StaticSoundSettings::default()).unwrap();
        info!("loaded file lasts for {:#?}", sound.duration());
        guard.insert(ID.into(), sound);
    }
    info!(
        "[red4ext] initialized audioware (thread: {:#?})",
        std::thread::current().id()
    );
}
pub fn detach() {
    info!("[red4ext] on detach audioware");
    *AUDIO.clone().borrow_mut().lock().unwrap() = Audioware(None);
    *REGISTRY.clone().borrow_mut().lock().unwrap() = HashMap::default();
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
    fn play_custom(&mut self, id: impl AsRef<str>) {
        info!(
            "[red4ext] play custom (thread: {:#?})",
            std::thread::current().id()
        );
        if let Some(ref mut manager) = self.0 {
            info!("[red4ext] audio manager about to play...");
            if let Ok(ref guard) = REGISTRY.clone().lock() {
                let map = guard.clone();
                let sound = map.get(id.as_ref()).unwrap().clone();
                let handle = manager.play(sound).unwrap();
                if let Ok(ref mut guard) = HANDLES.clone().borrow_mut().lock() {
                    guard.insert(ID.into(), handle);
                }
            }
        } else {
            warn!("for some reason there's no manager when there should be");
        }
    }
}

fn play_custom() {
    info!(
        "[red4ext] getting audio manager handle... (thread: {:#?})",
        std::thread::current().id()
    );
    info!(
        "[red4ext] audio manager handle exists (thread: {:#?})",
        std::thread::current().id()
    );
    if let Ok(mut guard) = (*AUDIO.clone().borrow_mut()).lock() {
        guard.play_custom(ID);
        info!(
            "[red4ext] audio manager finished playing! (thread: {:#?})",
            std::thread::current().id()
        );
    }
}
