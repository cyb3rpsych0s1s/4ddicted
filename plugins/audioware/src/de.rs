use serde::Deserialize;

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
