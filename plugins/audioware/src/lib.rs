use std::{
    borrow::BorrowMut,
    env::current_dir,
    sync::{Arc, Mutex},
};

use kira::{
    manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings},
    sound::static_sound::{StaticSoundData, StaticSoundSettings},
};
use red4ext_rs::{define_plugin, register_function};

define_plugin! {
    name: "audioware",
    author: "author",
    version: 0:1:0,
    on_register: {
        register_function!("PlayCustom", play_custom);
    }
}

// be careful everything works fine in-game
// but it flatlines on quit game
thread_local! {
    static AUDIO: Arc<Mutex<AudioManager::<DefaultBackend>>> = Arc::new(Mutex::new(AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap()));
}

fn play_custom() {
    let current = current_dir().unwrap(); // Cyberpunk 2077\bin\x64
    AUDIO.with(|mut handle| {
        let _ = (*handle.borrow_mut()).lock().unwrap().play(
            StaticSoundData::from_file(
                current
                    .join("..")
                    .join("..")
                    .join("mods")
                    .join("Addicted")
                    .join("customSounds")
                    .join("en-us")
                    .join("offhanded")
                    .join("fem_v_nic_v7VBWSUGf9Erb9upBsY2.wav")
                    .as_path(),
                StaticSoundSettings::default(),
            )
            .unwrap(),
        );
    });
}
