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

  if serious {
    let multiplier: Int32 = Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) ? 6 : 3;
    let value: Int32 = Min(5, count);
    let penalty: Int32 = value * multiplier;
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

@if(!ModuleExists("Edgerunning.System"))
public static func AlterNeuroBlockerStatusEffects(threshold: Threshold, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
  return actionEffects;
}

/// replace existing status effect with modified one
/// ObjectActionEffect_Record are immutable but actionEffects can be swapped
@if(ModuleExists("Edgerunning.System"))
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

@if(!ModuleExists("Edgerunning.System"))
public static func AlterBlackLaceStatusEffects(threshold: Threshold, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
  return actionEffects;
}
/// append status effect to existing one(s)
/// ObjectActionEffect_Record are immutable but actionEffects can be swapped
@if(ModuleExists("Edgerunning.System"))
public static func AlterBlackLaceStatusEffects(threshold: Threshold, actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
  let insanity = TweakDBInterface.GetObjectActionEffectRecord(t"Items.BlacklaceInsanityObjectActionEffect");
  let depot = GameInstance.GetResourceDepot();
  let edgerunner = depot.ArchiveExists("WannabeEdgerunner.archive");
  if !IsDefined(insanity) { F(s"could not find Items.BlacklaceInsanityObjectActionEffect"); }
  else {
    if edgerunner && !ArrayContains(actionEffects, insanity) {
      ArrayGrow(actionEffects, 1);
      ArrayInsert(actionEffects, ArraySize(actionEffects) -1, insanity);
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
    for suffix in suffixes {
      let effect: ref<StatusEffect_Record> = TweakDBInterface.GetStatusEffectRecord(TDBID.Create("BaseStatusEffect." + diminutive + suffix));
      let duration: ref<StatModifierGroup_Record> = effect.Duration();
      let uiData: ref<StatusEffectUIData_Record> = effect.UiData();
      let modifier: ref<ConstantStatModifier_Record> = duration.GetStatModifiersItem(0) as ConstantStatModifier_Record;
      let updated: Float;

      let value: Float = modifier.Value();
      for prefix in prefixes {
        updated = Equals(prefix, "NotablyWeakened") ? value / 2.0 : value / 4.0;

        let variantDuration: String = this.DeriveName(TDBID.ToStringDEBUG(duration.GetID()), prefix);
        let variantConstant: String = variantDuration + "Constant";
        if !IsDefined(TweakDBInterface.GetRecord(TDBID.Create(variantDuration))) {
          TweakDBManager.CloneRecord(StringToName(variantDuration), duration.GetID());
          TweakDBManager.CloneRecord(StringToName(variantConstant), duration.GetStatModifiersItem(0).GetID());
          
          let duration = TweakDBInterface.GetStatModifierGroupRecord(TDBID.Create(variantDuration));
          let modifiers: array<TweakDBID> = [TDBID.Create(variantConstant), duration.GetStatModifiersItem(1).GetID()];

          TweakDBManager.SetFlat(TDBID.Create(variantConstant + ".value"), updated);
          TweakDBManager.SetFlat(TDBID.Create(variantDuration + ".statModifiers"), modifiers);
          TweakDBManager.UpdateRecord(TDBID.Create(variantConstant));
          TweakDBManager.UpdateRecord(TDBID.Create(variantDuration));
        }

        let variantUIData: String = "BaseStatusEffect." + prefix + "UIData" + diminutive + suffix;
        if !IsDefined(TweakDBInterface.GetStatusEffectUIDataRecord(TDBID.Create(variantUIData))) {
          TweakDBManager.CloneRecord(StringToName(variantUIData), uiData.GetID());
          TweakDBManager.SetFlat(TDBID.Create(variantUIData + ".iconPath"), prefix + "Neuroblocker");
          TweakDBManager.UpdateRecord(TDBID.Create(variantUIData));
        }

        let variantEffect: String = this.DeriveName(TDBID.ToStringDEBUG(effect.GetID()), prefix);
        if !IsDefined(TweakDBInterface.GetStatusEffectRecord(TDBID.Create(variantEffect))) {
          TweakDBManager.CloneRecord(StringToName(variantEffect), effect.GetID());
          TweakDBManager.SetFlat(TDBID.Create(variantEffect + ".duration"), TDBID.Create(variantDuration));
          TweakDBManager.SetFlat(StringToName(variantEffect + ".uiData"), TDBID.Create(variantUIData));
          TweakDBManager.UpdateRecord(TDBID.Create(variantEffect));
        }

        let variantAction: String = "Items." + prefix + "ActionEffect" + diminutive + suffix;
        if !IsDefined(TweakDBInterface.GetObjectActionEffectRecord(TDBID.Create(variantAction))) {
          TweakDBManager.CreateRecord(StringToName(variantAction), n"ObjectActionEffect_Record");
          TweakDBManager.SetFlat(TDBID.Create(variantAction + ".statusEffect"), TDBID.Create(variantEffect));
          TweakDBManager.UpdateRecord(TDBID.Create(variantAction));
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
    