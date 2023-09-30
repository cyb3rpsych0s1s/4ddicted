module Addicted

import Addicted.System

native func OnStatusEffectNotAppliedOnSpawn(system: ref<System>, id: TweakDBID) -> Void;

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let system = System.GetInstance(this.m_gameInstance);
    system.OnSkipTime();
  }
  wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    if !evt.isAppliedOnSpawn {
      let system = System.GetInstance(this.GetGame());
      let id = evt.staticData.GetID();
      OnStatusEffectNotAppliedOnSpawn(system, id);
    }
}