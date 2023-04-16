module Addicted.Crossover

@if(ModuleExists("Edgerunning.System"))
import Edgerunning.System.EdgerunningSystem

import Addicted.System.AddictedSystem
import Addicted.Threshold
import Addicted.Helper
import Addicted.Consumable
import Addicted.Utils.{E,F}

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
public static func AlterNeuroBlockerStatusEffects(threshold: Threshold, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
  let weakened: String = "NotablyWeakened";
  if EnumInt(threshold) == EnumInt(Threshold.Severely) { weakened = "SeverelyWeakened"; }
  let effect = (actionEffects[0] as ObjectActionEffect_Record).StatusEffect();
  let id: TweakDBID = effect.GetID();
  let str: String = TDBID.ToStringDEBUG(id);
  let suffix: String = StrAfterFirst(str, ".");
  let weaker = TDBID.Create("Items." + weakened + suffix);
  let replacer = TweakDBInterface.GetObjectActionEffectRecord(weaker);
  actionEffects[0] = replacer;
  return actionEffects;
}

/// append status effect to existing one(s)
/// ObjectActionEffect_Record are immutable but actionEffects can be swapped
public static func AlterBlackLaceStatusEffects(threshold: Threshold, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
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

public class NeuroBlockerTweaks extends ScriptableTweak {
  protected cb func OnApply() -> Void {
    let notably   = "NotablyWeakened";
    let severely  = "SeverelyWeakened";
    let prefixes  = [notably, severely];

    let item      = "RipperDocMedBuff";

    let depot = GameInstance.GetResourceDepot();
    let edgerunner = depot.ArchiveExists("WannabeEdgerunner.archive");

    if edgerunner {
      this.Derive(prefixes, item, ["", "Uncommon", "Common"]);
    }
  }

  // create object action effect for weakened neuroblockers :
  // e.g. Items.NotablyWeakenedActionEffectRipperDocMedBuff for completionEffects
  // with status effect set as BaseStatusEffect.NotablyWeakenedRipperDocMedBuff
  private func Derive(prefixes: array<String>, diminutive: String, suffixes: array<String>) -> Void {
    for prefix in prefixes {
      for suffix in suffixes {
        let effect: ref<StatusEffect_Record> = TweakDBInterface.GetStatusEffectRecord(TDBID.Create("BaseStatusEffect." + diminutive + suffix));
        let duration: ref<StatModifierGroup_Record> = effect.Duration();
        let modifier: ref<ConstantStatModifier_Record> = duration.GetStatModifiersItem(0) as ConstantStatModifier_Record;

        let value: Float = modifier.Value();
        let updated: Float = Equals(prefix, "NotablyWeakened") ? value / 2.0 : value / 4.0;

        let variantDuration: String = this.DeriveName(TDBID.ToStringDEBUG(duration.GetID()), prefix);
        if !IsDefined(TweakDBInterface.GetRecord(TDBID.Create(variantDuration))) {
          TweakDBManager.CloneRecord(StringToName(variantDuration), duration.GetID());
          TweakDBManager.SetFlat(TDBID.Create(variantDuration + ".statModifiers.0.value"), updated);
          TweakDBManager.UpdateRecord(TDBID.Create(variantDuration));
          E(s"created: \(variantDuration)");
        }

        let variantEffect: String = this.DeriveName(TDBID.ToStringDEBUG(effect.GetID()), prefix);
        if !IsDefined(TweakDBInterface.GetStatusEffectRecord(TDBID.Create(variantEffect))) {
          TweakDBManager.CloneRecord(StringToName(variantEffect), effect.GetID());
          TweakDBManager.SetFlat(TDBID.Create(variantEffect + ".duration"), TweakDBInterface.GetStatModifierGroupRecord(TDBID.Create(variantDuration)));
          TweakDBManager.UpdateRecord(TDBID.Create(variantEffect));
          E(s"created: \(variantEffect)");
        }

        let variantAction: String = "Items." + prefix + "ActionEffect" + diminutive + suffix;
        if !IsDefined(TweakDBInterface.GetObjectActionEffectRecord(TDBID.Create(variantAction))) {
          TweakDBManager.CreateRecord(StringToName(variantAction), n"ObjectActionEffect_Record");
          TweakDBManager.SetFlat(TDBID.Create(variantAction + ".statusEffect"), TweakDBInterface.GetStatusEffectRecord(TDBID.Create(variantEffect)));
          TweakDBManager.UpdateRecord(TDBID.Create(variantAction));
          E(s"created: \(variantAction)");
        }
      }
    }
  }

  // given e.g. Items.RipperdocMedDurationRare and NotablyWeakened
  // will return Items.NotablyWeakenedRipperdocMedDurationRare
  private func DeriveName(base: String, prepend: String) -> String {
    let prefix: String;
    let suffix: String;
    StrSplitFirst(base, ".", prefix, suffix);
    return prefix + "." + prepend + suffix;
  }
}
    