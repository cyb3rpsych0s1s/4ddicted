module Addicted.Crossover

@if(ModuleExists("Edgerunning.System"))
import Edgerunning.System.EdgerunningSystem

import Addicted.System.AddictedSystem
import Addicted.Threshold
import Addicted.Helper
import Addicted.Consumable
import Addicted.Utils.E

@if(!ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
protected func HandleHumanityPenalty(count: Int32, threshold: Threshold) -> Void {}

@if(ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
protected func HandleHumanityPenalty(count: Int32, threshold: Threshold) -> Void {
  let edgerunning: ref<EdgerunningSystem> = EdgerunningSystem.GetInstance(this.GetGame()) as EdgerunningSystem;
  let current: Int32 = edgerunning.GetPenaltyByKey("Mod-Addicted-Edgerunning-BlackLace-Penalty");
  let exists: Bool = NotEquals(current, -1);
  let serious: Bool = Helper.IsSerious(threshold);
  E(s"handle humanity penalty (wannabe edgerunner)\ncount: \(count), current: \(current), exists: \(exists), threshold: \(ToString(threshold)), serious: \(serious)");

  if serious {
    let multiplier: Int32 = Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) ? 6 : 3;
    let value: Int32 = Min(5, count);
    let penalty: Int32 = value * multiplier;
    E(s"current penalty \(current), updated penalty \(penalty)");
    if NotEquals(current, penalty) {
      edgerunning.AddHumanityPenalty("Mod-Addicted-Edgerunning-BlackLace-Penalty", penalty);
    }
    return;
  }
  if !serious && exists {
    edgerunning.RemoveHumanityPenalty("Mod-Addicted-Edgerunning-BlackLace-Penalty");
    return;
  }
}

/// replace existing status effect with modified one
/// ObjectActionEffect_Record are immutable but actionEffects can be swapped
public static func AlterNeuroBlockerStatusEffects(system: ref<AddictedSystem>, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
  let neuro = this.Threshold(Consumable.NeuroBlocker);
  let weakened: String = "NotablyWeakened";
  if EnumInt(neuro) == EnumInt(Threshold.Severely) { weakened = "SeverelyWeakened"; }
  let effect = (actionEffects[0] as ObjectActionEffect_Record).StatusEffect();
  let id: TweakDBID = effect.GetID();
  let str: String = TDBID.ToStringDEBUG(id);
  let prefix: String;
  let suffix: String;
  let split = StrSplitFirst(str, ".", prefix, suffix);
  let replacer = TweakDBID.Create(prefix + "." + weakened + suffix);
  actionEffects[0] = replacer;
  return actionEffects;
}

/// append status effect to existing one(s)
/// ObjectActionEffect_Record are immutable but actionEffects can be swapped
public static func AlterBlackLaceStatusEffects(_: ref<AddictedSystem>, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
  let insanity = TweakDBInterface.GetObjectActionEffectRecord(t"Items.BlacklaceInsanityObjectActionEffect");
  let depot = GameInstance.GetResourceDepot();
  let edgerunner = depot.ArchiveExists("WannabeEdgerunner.archive");
  if !IsDefined(insanity) { F(s"could not find Items.BlacklaceInsanityObjectActionEffect"); }
  else {
    if edgerunner && !ArrayContains(actionEffects, insanity) {
      E(s"about to grow action effects array...");
      ArrayGrow(actionEffects, 1);
      ArrayInsert(actionEffects, ArraySize(actionEffects) -1, insanity);
      E(s"add insanity object action effect record to blacklace's existing one(s)");
    }
  }
  return actionEffects;
}
    