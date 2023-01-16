module Addicted

import Addicted.Threshold
import Addicted.System.AddictedSystem
import Addicted.Utils.{E,EI}

// use like:
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.FirstAidWhiffV0"), 40);
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.BonesMcCoy70V0"), 40);
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.MemoryBooster"), 40);
// where '40' matches Threshold variant
@addMethod(PlayerPuppet)
public func DebugSwitchThreshold(id: TweakDBID, threshold: Int32) -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugSwitchThreshold(id, IntEnum(threshold));
}

// use like: Game.GetPlayer():DebugThresholds();
@addMethod(PlayerPuppet)
public func DebugThresholds() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugThresholds();
}

// use like: Game.GetPlayer():DebugClear();
@addMethod(PlayerPuppet)
public func DebugClear() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugClear();
}

// use like: Game.GetPlayer():DebugClearEffects();
@addMethod(PlayerPuppet)
public func DebugClearEffects() -> Void {
  StatusEffectHelper.RemoveAllStatusEffects(this);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
  wrappedMethod(evt);
  // let id = evt.staticData.GetID();
  // let record = TweakDBInterface.GetStatusEffectRecord(id);
  // let debugTags = record.DebugTags();
  // if ArraySize(debugTags) == 0 { EI(id, s"[DEBUG TAGS] NO TAG!"); }
  // for tag in debugTags {
  //   EI(id, s"[DEBUG TAGS] \(ToString(tag))");
  // }
  // let gameplayTags = record.GameplayTags();
  // if ArraySize(gameplayTags) == 0 { EI(id, s"[GAMEPLAY TAGS] NO TAG!"); }
  // for tag in gameplayTags {
  //   EI(id, s"[GAMEPLAY TAGS] \(ToString(tag))");
  // }
  // let records = TweakDBInterface.GetRecords(n"ConsumableItem_Record");
  // EI(id, ToString(ArraySize(records)));
  // let consumable: ref<ConsumableItem_Record>;
  // for rec in records {
  //   consumable = rec as ConsumableItem_Record;
  //   EI(rec.GetID(), s"\(consumable.ConsumableBaseName().Type()): \(consumable.ConsumableType().Type())");
  // }
  // let effectRecords = TweakDBInterface.GetRecords(n"StatusEffect_Record");
  // let effect: ref<StatusEffect_Record>;
  // for effectRecord in effectRecords {
  //   effect = effectRecord as StatusEffect_Record;
  //   let effectTags = effect.GameplayTags();
  //   for effectTag in effectTags {
  //     let ido = effect.GetID();
  //     if Helper.IsMaxDOC(ido) {
  //       EI(ido, ToString(effectTag));
  //     }
  //   }
  // }
}