use std::borrow::BorrowMut;
use red4ext_rs::error;
use crate::{mods_game_dir, REGISTRY, interop::Bank};

pub struct Registry;

impl Registry {
    pub fn setup() -> anyhow::Result<()> {
        let mods = std::fs::read_dir(mods_game_dir())?;
        for rsrc in mods {
            let folder = rsrc?;
            if folder.path().is_dir() {
                let manifest = folder.path().join("audioware.yml");
                let foldername = folder.file_name().to_string_lossy().to_string();
                if manifest.exists() && manifest.is_file() {
                    let content = std::fs::read_to_string(manifest.clone())?;
                    let bank = serde_yaml::from_str::<Bank>(&content)?;
                    if Self::insert(foldername.as_str(), bank)?.is_some() {
                        error!("bank previously existed for {foldername}");
                    }
                }
            }
        }
        Ok(())
    }
    pub fn insert(module: impl AsRef<str>, bank: Bank) -> anyhow::Result<Option<Bank>> {
        match REGISTRY.clone().borrow_mut().try_lock() {
            Ok(mut guard) => Ok(guard.insert(module, bank)),
            Err(_) => anyhow::bail!("couldn't acquire lock")
        }
    }
}
