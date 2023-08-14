use std::{
    borrow::BorrowMut,
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

thread_local! {
    static AUDIO: Arc<Mutex<AudioManager::<DefaultBackend>>> = Arc::new(Mutex::new(AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap()));
}

fn play_custom() {
    AUDIO.with(|mut handle| {
        let _ = (*handle.borrow_mut())
            .lock()
            .unwrap()
            .play(StaticSoundData::from_file(
                "archive\\source\\customSounds\\fr-fr\\surprised\\fem_v_b_T9zcts4PeNolNadsX23D.wav",
                StaticSoundSettings::default(),
            ).unwrap());
    });
}
