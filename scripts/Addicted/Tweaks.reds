module Addicted

import Addicted.System.AddictedSystem
import Addicted.Helper
import Addicted.Utils.E

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    E(s"status effect applied \(TDBID.ToStringDEBUG(id))");
    // increase score on consumption
    if evt.isNewApplication && evt.IsAddictive() {
        E(s"consumed addictive substance \(TDBID.ToStringDEBUG(id))");
        system.OnConsumed(id);
    }
    // decrease score on rest
    if id == t"HousingStatusEffect.Rested" {
        E(s"rested \(TDBID.ToStringDEBUG(id))");
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    if evt.IsAddictive() {
        E(s"addictive substance \(TDBID.ToStringDEBUG(id)) dissipated");
        system.OnDissipated(id);
    }
    return wrappedMethod(evt);
}

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
  E(s"process status effects");
  let healing = false;
  for record in actionEffects {
    E(s"processing \(TDBID.ToStringDEBUG(record.GetID()))...");
    if Helper.IsHealerAction(record.GetID()) {
      healing = true;
      break;
    }
  }
  let effects = actionEffects;
  if healing {
    let system = AddictedSystem.GetInstance(gameInstance);
    effects = system.OnProcessHealerEffect(actionEffects);
  }
  wrappedMethod(effects, gameInstance);
}

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
  let id = this.staticData.GetID();
  return Helper.IsAddictive(id);
}