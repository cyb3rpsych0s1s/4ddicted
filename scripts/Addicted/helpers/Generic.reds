module Addicted.Helpers

import Addicted.*

// effects or items agnostic
public class Generic {

  public static func Consumable(id: TweakDBID) -> Consumable {
    if Generic.IsAlcohol(id)          { return Consumable.Alcohol; }
    if Generic.IsMaxDOC(id)           { return Consumable.MaxDOC; }
    if Generic.IsBounceBack(id)       { return Consumable.BounceBack; }
    if Generic.IsHealthBooster(id)    { return Consumable.HealthBooster; }
    if Generic.IsCapacityBooster(id)  { return Consumable.CarryCapacityBooster; }
    if Generic.IsStaminaBooster(id)   { return Consumable.StaminaBooster; }
    if Generic.IsMemoryBooster(id)    { return Consumable.MemoryBooster; }
    if Generic.IsBlackLace(id)        { return Consumable.BlackLace; }
    if Generic.IsOxyBooster(id)       { return Consumable.OxyBooster; }
    if Generic.IsNeuroBlocker(id)     { return Consumable.NeuroBlocker; }
    return Consumable.Invalid;
  }

  public static func Addiction(consumable: Consumable) -> Addiction {
    switch consumable {
      case Consumable.MaxDOC:
      case Consumable.BounceBack:
      case Consumable.HealthBooster:
        return Addiction.Healers;
      case Consumable.StaminaBooster:
      case Consumable.CarryCapacityBooster:
        return Addiction.Anabolics;
      case Consumable.MemoryBooster:
      case Consumable.NeuroBlocker:
        return Addiction.Neuros;
      case Consumable.BlackLace:
        return Addiction.BlackLace;
      case Consumable.Alcohol:
        return Addiction.Alcohol;
      default:
        break;
    }
    return Addiction.Invalid;
  }

  public static func IsBiomonitor(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrBeginsWith(suffix, "HealthMonitor");
  }

  public static func IsAddictive(id: TweakDBID) -> Bool {
    // t"BaseStatusEffect.CombatStim" double-check
    return !Generic.IsOxyBooster(id) &&
    (Generic.IsLiquid(id) ||
    Generic.IsInhaler(id) ||
    Generic.IsInjector(id) ||
    Generic.IsPill(id) ||
    Generic.IsKit(id));
  }

  public static func IsInstant(id: ItemID) -> Bool {
    let record = TweakDBInterface.GetRecord(ItemID.GetTDBID(id));
    let effect = Effect.IsInstant(record);
    if effect { return true; }
    let item = Items.IsInstant(record);
    if item { return true; }
    return false;
  }

  public static func IsLiquid(id: TweakDBID) -> Bool {
    return Generic.IsAlcohol(id);
  }

  public static func IsPill(id: TweakDBID) -> Bool {
    return Generic.IsCapacityBooster(id) ||
    Generic.IsStaminaBooster(id) ||
    Generic.IsMemoryBooster(id);
  }

  public static func IsInhaler(id: TweakDBID) -> Bool {
    return Generic.IsMaxDOC(id) || Generic.IsBlackLace(id) || Generic.IsOxyBooster(id);
  }

  public static func IsInjector(id: TweakDBID) -> Bool {
    return Generic.IsBounceBack(id) || Generic.IsNeuroBlocker(id);
  }

  public static func IsKit(id: TweakDBID) -> Bool {
    return Generic.IsHealthBooster(id);
  }

  public static func IsBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "Booster");
  }

  public static func IsHealer(id: TweakDBID) -> Bool {
    return Generic.IsMaxDOC(id) || Generic.IsBounceBack(id) || Generic.IsHealthBooster(id);
  }

  public static func IsAnabolic(id: TweakDBID) -> Bool {
    return Generic.IsCapacityBooster(id) || Generic.IsStaminaBooster(id);
  }

  public static func IsNeurotransmitter(id: TweakDBID) -> Bool {
    return Generic.IsMemoryBooster(id) || Generic.IsNeuroBlocker(id);
  }

  public static func IsAlcohol(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    return StrContains(str, "Alcohol");
  }

  public static func IsMaxDOC(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "FirstAidWhiff");
  }

  public static func IsBounceBack(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "BonesMcCoy70");
  }

  public static func IsHealthBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "HealthBooster");
  }

  public static func IsBlackLace(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "BlackLace");
  }

  public static func IsCapacityBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "CarryCapacityBooster");
  }

  public static func IsStaminaBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "StaminaBooster");
  }

  public static func IsMemoryBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "MemoryBooster");
  }

  public static func IsOxyBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "OxyBooster");
  }

  public static func IsNeuroBlocker(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "RipperDocMedBuff") || StrContains(suffix, "ripperdoc_med");
  }
}