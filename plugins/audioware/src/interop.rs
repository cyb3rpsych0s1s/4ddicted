use std::collections::{hash_map::Keys, HashMap};

use kira::sound::static_sound::{StaticSoundData, StaticSoundSettings};
use red4ext_rs::{info, prelude::NativeRepr, types::RedString};
use serde::Deserialize;

use crate::mods_game_dir;

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
pub enum Locale {
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
pub struct Audio {
    path: String,
    kind: AudioKind,
    #[serde(skip)]
    duration: f64,
    subtitles: Option<Subtitles>,
}
impl Audio {
    pub fn path(&self) -> &str {
        self.path.as_str()
    }
    pub fn subtitles(&self) -> Option<&Subtitles> {
        self.subtitles.as_ref()
    }
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
impl<'a> Selection<'a> {
    pub fn new(module: &'a str, audio: &'a Audio) -> Self {
        Self(module, audio)
    }
}

#[derive(Debug, Clone, PartialEq, Deserialize)]
pub struct Subtitles {
    id: String,
    translations: HashMap<Locale, SubtitleVariant>,
}
impl Subtitles {
    pub fn translations(&self) -> &HashMap<Locale, SubtitleVariant> {
        &self.translations
    }
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct Bank(HashMap<String, Audio>);
impl Bank {
    pub fn get(&self, sfx: impl AsRef<str>) -> Option<&Audio> {
        self.0.get(sfx.as_ref())
    }
    pub fn keys(&self) -> Keys<'_, String, Audio> {
        self.0.keys()
    }
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct Banks(HashMap<String, Bank>);
impl Banks {
    pub fn get(&self, module: impl AsRef<str>) -> Option<&Bank> {
        self.0.get(module.as_ref())
    }
    pub fn insert(&mut self, module: impl AsRef<str>, bank: Bank) -> Option<Bank> {
        self.0.insert(module.as_ref().to_string(), bank)
    }
}

#[repr(C)]
pub struct Translation {
    locale: Locale,
    female: RedString,
    male: RedString,
}
impl From<(Locale, &SubtitleVariant)> for Translation {
    fn from((locale, variant): (Locale, &SubtitleVariant)) -> Self {
        match variant {
            SubtitleVariant::Neutral(variant) => Self {
                locale,
                female: RedString::new(variant.as_str()),
                male: RedString::new(variant.as_str()),
            },
            SubtitleVariant::Sensitive(Subtitle { female, male }) => Self {
                locale,
                female: RedString::new(female.as_str()),
                male: RedString::new(male.as_str()),
            },
        }
    }
}

unsafe impl NativeRepr for Translation {
    // this needs to refer to an actual in-game type name
    const NAME: &'static str = "Translation";
}

#[derive(Debug, Clone, Deserialize, PartialEq)]
pub struct Subtitle {
    pub female: String,
    pub male: String,
}

#[derive(Debug, Clone, Deserialize, PartialEq)]
#[serde(untagged)]
pub enum SubtitleVariant {
    Neutral(String),
    Sensitive(Subtitle),
}
