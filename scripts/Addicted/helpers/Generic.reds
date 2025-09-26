module Addicted.Helpers

import Addicted.*

// effects or items agnostic
public class Generic {
  public static func Consumable(id: ItemID) -> Consumable = Generic.Consumable(ItemID.GetTDBID(id));
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
    if Generic.IsAddiquit(id)         { return Consumable.Addiquit; }
    if Generic.IsTobacco(id)
    || Generic.IsLighter(id)          { return Consumable.Tobacco; }
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
      case Consumable.Tobacco:
        return Addiction.Tobacco;
      case Consumable.Addiquit:
        return Addiction.Substitute;
      default:
        break;
    }
    return Addiction.Invalid;
  }

  public static func IsBiomonitor(id: TweakDBID) -> Bool = Generic.SuffixContains(id, "HealthMonitor") || Generic.SuffixContains(id, "Biomonitor");

  // t"BaseStatusEffect.CombatStim" double-check
  public static func IsAddictive(id: TweakDBID) -> Bool = !Generic.IsOxyBooster(id) &&
    (Generic.IsLiquid(id) || Generic.IsInhaler(id) || Generic.IsInjector(id) || Generic.IsPill(id) || Generic.IsKit(id));

  public static func IsInstant(id: ItemID) -> Bool {
    let record = TweakDBInterface.GetRecord(ItemID.GetTDBID(id));
    let effect = Effect.IsInstant(record);
    if effect { return true; }
    let item = Items.IsInstant(record);
    if item { return true; }
    return false;
  }

  public static func IsLiquid(id: TweakDBID) -> Bool            = Generic.IsAlcohol(id);
  public static func IsPill(id: TweakDBID) -> Bool              = Generic.IsCapacityBooster(id) || Generic.IsStaminaBooster(id) || Generic.IsMemoryBooster(id);
  public static func IsInhaler(id: TweakDBID) -> Bool           = Generic.IsMaxDOC(id) || Generic.IsBlackLace(id) || Generic.IsOxyBooster(id) || Generic.IsAddiquit(id);
  public static func IsInjector(id: TweakDBID) -> Bool          = Generic.IsBounceBack(id) || Generic.IsNeuroBlocker(id);
  public static func IsKit(id: TweakDBID) -> Bool               = Generic.IsHealthBooster(id);
  public static func IsBooster(id: TweakDBID) -> Bool           = Generic.SuffixContains(id, "Booster");
  public static func IsHealer(id: TweakDBID) -> Bool            = Generic.IsMaxDOC(id) || Generic.IsBounceBack(id) || Generic.IsHealthBooster(id);
  public static func IsAnabolic(id: TweakDBID) -> Bool          = Generic.IsCapacityBooster(id) || Generic.IsStaminaBooster(id);
  public static func IsNeurotransmitter(id: TweakDBID) -> Bool  = Generic.IsMemoryBooster(id) || Generic.IsNeuroBlocker(id);

  public static func IsAlcohol(id: TweakDBID) -> Bool           = Generic.Contains(id, "Alcohol");
  public static func IsTobacco(id: TweakDBID) -> Bool           = Generic.Contains(id, "cigar");
  public static func IsLighter(id: TweakDBID) -> Bool           = Generic.Contains(id, "lighter");
  public static func IsMaxDOC(id: TweakDBID) -> Bool            = Generic.SuffixContains(id, "FirstAidWhiff");
  public static func IsBounceBack(id: TweakDBID) -> Bool        = Generic.SuffixContains(id, "BonesMcCoy70");
  public static func IsHealthBooster(id: TweakDBID) -> Bool     = Generic.SuffixContains(id, "HealthBooster");
  public static func IsBlackLace(id: TweakDBID) -> Bool         = Generic.SuffixContains(id, "BlackLace");
  public static func IsCapacityBooster(id: TweakDBID) -> Bool   = Generic.SuffixContains(id, "CarryCapacityBooster");
  public static func IsStaminaBooster(id: TweakDBID) -> Bool    = Generic.SuffixContains(id, "StaminaBooster");
  public static func IsMemoryBooster(id: TweakDBID) -> Bool     = Generic.SuffixContains(id, "MemoryBooster");
  public static func IsOxyBooster(id: TweakDBID) -> Bool        = Generic.SuffixContains(id, "OxyBooster");
  public static func IsNeuroBlocker(id: TweakDBID) -> Bool      = Generic.SuffixContains(id, "RipperDocMedBuff") || Generic.SuffixContains(id, "ripperdoc_med");
  public static func IsAddiquit(id: TweakDBID) -> Bool          = Equals(id, t"DarkFutureItem.AddictionTreatmentDrug");
  
  public static func IsContraindicated(id: TweakDBID) -> Bool   = Generic.SuffixContains(id, "contraindication");

  public static func Contains(id: TweakDBID, word: String) -> Bool       = StrContains(TDBID.ToStringDEBUG(id), word);
  public static func SuffixContains(id: TweakDBID, word: String) -> Bool = StrContains(StrAfterFirst(TDBID.ToStringDEBUG(id), "."), word);
}
