use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, Ref, TweakDbId, WRef}, call,
};

use crate::GameObject;

#[derive(Debug)]
pub struct StatusEffectHelper;

impl ClassType for StatusEffectHelper {
    type BaseClass = IScriptable;
    const NAME: &'static str = "StatusEffectHelper";
}

// issue with `GameObject` expected in signature yet `whandle:gameObject` expected when performing call!
//
// #[redscript_import]
// impl StatusEffectHelper {
//     /// `public static ApplyStatusEffect(target: GameObject, statusEffectID: TweakDBID, opt delay: Float): Bool`
//     pub fn apply_status_effect(target: WRef<GameObject>, id: TweakDbId, delay: f32) -> bool;
//     /// `public static RemoveStatusEffect(target: GameObject, statusEffectID: TweakDBID, opt removeCount: Uint32): Bool`
//     pub fn remove_status_effect(target: WRef<GameObject>, id: TweakDbId, count: u32) -> bool;
// }

impl StatusEffectHelper {
    pub fn apply_status_effect(target: WRef<GameObject>, id: TweakDbId, delay: f32) -> bool {
        call!("StatusEffectHelper::ApplyStatusEffect;GameObjectTweakDBIDFloat" (target, id, delay) -> bool)
    }
    pub fn remove_status_effect(target: WRef<GameObject>, id: TweakDbId, count: u32) -> bool {
        call!("StatusEffectHelper::RemoveStatusEffect;GameObjectTweakDBIDUint32" (target, id, count) -> bool)
    }
}
