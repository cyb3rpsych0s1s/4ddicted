module Addicted

import Addicted.System

native func OnStatusEffectNotAppliedOnSpawn(system: ref<System>, id: TweakDBID) -> Void;

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    let system = System.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    if !evt.isAppliedOnSpawn {
      OnStatusEffectNotAppliedOnSpawn(system, id);
    }
}