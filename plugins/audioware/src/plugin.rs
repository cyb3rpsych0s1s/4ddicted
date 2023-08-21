use std::borrow::BorrowMut;

use kira::{
    manager::{backend::DefaultBackend, AudioManager},
    sound::static_sound::StaticSoundData,
};
use red4ext_rs::{info, warn};

use crate::{interop::Selection, AUDIO, HANDLES, REGISTRY};

#[derive(Default)]
pub struct Audioware(Option<AudioManager<DefaultBackend>>);

impl Audioware {
    pub fn create(manager: AudioManager) -> anyhow::Result<()> {
        match AUDIO.clone().borrow_mut().try_lock() {
            Ok(mut guard) => {
                *guard = Self(Some(manager));
                Ok(())
            }
            Err(_) => anyhow::bail!("unable to create audioware"),
        }
    }
    pub fn clear() -> anyhow::Result<()> {
        match AUDIO.clone().borrow_mut().try_lock() {
            Ok(mut guard) => {
                *guard = Self(None);
                Ok(())
            }
            Err(_) => anyhow::bail!("unable to clear audioware"),
        }
    }
    pub fn play_custom(&mut self, module: impl AsRef<str>, id: impl AsRef<str>) -> bool {
        info!("play custom (thread: {:#?})", std::thread::current().id());
        if let Some(ref mut manager) = self.0 {
            info!("audio manager about to play...");
            if let Ok(ref guard) = REGISTRY.clone().try_lock() {
                let banks = guard.clone();
                if let Some(bank) = banks.get(module.as_ref()) {
                    if let Some(audio) = bank.get(id.as_ref()) {
                        if let Ok(data) =
                            StaticSoundData::try_from(&Selection::new(module.as_ref(), audio))
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
                                warn!("unable to play static sound data from: {}", audio.path());
                            }
                        } else {
                            warn!("unable to get static sound data from: {}", audio.path());
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
