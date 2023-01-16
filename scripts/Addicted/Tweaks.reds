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
    if !evt.isAppliedOnSpawn && Helper.IsHousing(id) {
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
  let effects: array<wref<ObjectActionEffect_Record>>;
  if healing {
    effects = system.OnProcessHealerEffects(actionEffects);
  } else {
    effects = actionEffects;
  }
  wrappedMethod(effects, gameInstance);
}

@wrapMethod(ConsumeAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  wrappedMethod(gameInstance);
  let system = AddictedSystem.GetInstance(gameInstance);
  system.Noisy();
}

@wrapMethod(ItemActionsHelper)
public final static func ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
  let system = AddictedSystem.GetInstance(gameInstance);
  system.Quiet();
  wrappedMethod(executor, itemID, fromInventory);
}

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
  let id = this.staticData.GetID();
  return Helper.IsAddictive(id);
}