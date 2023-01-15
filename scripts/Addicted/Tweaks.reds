module Addicted

import Addicted.System.AddictedSystem
import Addicted.Helper
import Addicted.Utils.{E,EI}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    EI(id, s"status effect applied");
    // increase score on consumption
    if evt.isNewApplication && evt.IsAddictive() {
        EI(id, s"consumed addictive substance");
        system.OnConsumed(id);
    }
    // decrease score on rest
    if Helper.IsHousing(id) {
        EI(id, s"housing");
        system.OnRested();
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    if evt.IsAddictive() {
        EI(id, s"addictive substance dissipated");
        system.OnDissipated(id);
    }
    return wrappedMethod(evt);
}

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
  E(s"process status effects");
  let healing = false;
  for record in actionEffects {
    EI(record.GetID(), s"checking if healer action effect");
    if Helper.IsHealer(record.GetID()) {
      healing = true;
      break;
    }
  }
  let effects = actionEffects;
  if healing {
    let system = AddictedSystem.GetInstance(gameInstance);
    effects = system.OnProcessHealerEffects(actionEffects);
  }
  wrappedMethod(effects, gameInstance);
}

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
  let id = this.staticData.GetID();
  return Helper.IsAddictive(id);
}