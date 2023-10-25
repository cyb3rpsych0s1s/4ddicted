use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, TweakDbId, WRef},
};

use crate::GameObject;

#[derive(Debug)]
pub struct StatusEffectHelper;

impl ClassType for StatusEffectHelper {
    type BaseClass = IScriptable;
    const NAME: &'static str = "StatusEffectHelper";
}

#[redscript_import]
impl StatusEffectHelper {
    /// `public static func ApplyStatusEffect(target: wref<GameObject>, statusEffectID: TweakDBID, opt delay: Float): Bool`
    pub fn apply_status_effect(target: WRef<GameObject>, id: TweakDbId, delay: f32) -> bool;
    /// `public static func RemoveStatusEffect(target: wref<GameObject>, statusEffectID: TweakDBID, opt removeCount: Uint32): Bool`
    pub fn remove_status_effect(target: WRef<GameObject>, id: TweakDbId, count: u32) -> bool;
}
