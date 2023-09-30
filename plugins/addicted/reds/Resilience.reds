module Addicted

import Addicted.System

public native func OnStatusEffectNotAppliedOnSpawn(system: ref<System>, id: TweakDBID) -> Void;

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    if !evt.isAppliedOnSpawn {
      let system = System.GetInstance(this.GetGame());
      let id = evt.staticData.GetID();
      OnStatusEffectNotAppliedOnSpawn(system, id);
    }
}