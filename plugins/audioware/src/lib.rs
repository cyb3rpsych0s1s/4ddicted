use std::{
    borrow::BorrowMut,
    env::current_dir,
    sync::{Arc, Mutex},
    time::Duration, path::Path,
};

use kira::{
    manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings},
    sound::static_sound::{StaticSoundData, StaticSoundSettings},
};
// use metadata::MediaFileMetadata;
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

thread_local! {
    static AUDIO: Arc<Mutex<Audioware>> = Arc::new(Mutex::new(Audioware::default()));
}

pub fn attach() {
    info!("[red4ext] on attach audioware");
    AUDIO.with(|mut handle| {
        let manager = AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap();
        *handle.borrow_mut().lock().unwrap() = Audioware(Some(manager));
        info!("[red4ext] initialized audioware (thread: {:#?})", std::thread::current().id());
    });
}
pub fn detach() {
    info!("[red4ext] on detach audioware");
    AUDIO.with(|mut handle| {
        *handle.borrow_mut().lock().unwrap() = Audioware(None);
        info!("[red4ext] cleaned audioware (thread: {:#?})", std::thread::current().id());
    });
}

pub struct Audioware(Option<AudioManager<DefaultBackend>>);
impl Default for Audioware {
    fn default() -> Self {
        Self(None)
    }
}
impl Audioware {
    fn play_custom(&mut self, filepath: impl AsRef<Path>) {
        info!("[red4ext] play custom (thread: {:#?})", std::thread::current().id());
        if let Some(ref mut manager) = self.0 {
            info!("[red4ext] audio manager about to play...");
            let _ = manager.play(
                StaticSoundData::from_file(filepath, StaticSoundSettings::default())
                    .unwrap(),
            );
        } else {
            warn!("for some reason there's no manager when there should be");
        }
    }
}

fn play_custom() {
    info!("[red4ext] getting audio manager handle... (thread: {:#?})", std::thread::current().id());
    AUDIO.with(|mut handle| {
        info!("[red4ext] audio manager handle exists (thread: {:#?})", std::thread::current().id());
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
        if let Ok(mut guard) = (*handle.borrow_mut()).lock() {
            guard.play_custom(&filepath);
            // let duration = MediaFileMetadata::new(&filepath)
            //     .unwrap()
            //     ._duration
            //     .unwrap();
            let duration: f64 = 1.5;
            std::thread::sleep(Duration::from_secs_f64(duration));
            info!("[red4ext] audio manager finished playing! (thread: {:#?})", std::thread::current().id());
        }
    });
}
