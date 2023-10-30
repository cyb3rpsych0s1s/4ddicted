module Addicted

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let system = System.GetInstance(this.m_gameInstance);
    system.restingSince = system.TimeSystem().GetGameTime();
  }
  wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let applied = wrappedMethod(evt);

    if !evt.isAppliedOnSpawn {
      let system = System.GetInstance(this.GetGame());
      let id = evt.staticData.GetID();
      switch(id) {
        case t"HousingStatusEffect.Rested":
          system.Rested();
          break;
        case t"HousingStatusEffect.Refreshed":
          system.Refreshed();
          break;
        case t"HousingStatusEffect.Energized":
          system.Energized();
          break;
      }
    }

    return applied;
}
