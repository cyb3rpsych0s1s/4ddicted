module Addicted.Helpers

import Addicted.*
import Addicted.Utils.E

public class Translations {

  public static func Threshold(threshold: Threshold) -> String {
    switch (threshold) {
      case Threshold.Severely:
        return GetLocalizedTextByKey(n"Mod-Addicted-Threshold-Severely");
      case Threshold.Notably:
        return GetLocalizedTextByKey(n"Mod-Addicted-Threshold-Notably");
      case Threshold.Mildly:
        return GetLocalizedTextByKey(n"Mod-Addicted-Threshold-Mildly");
      case Threshold.Barely:
        return GetLocalizedTextByKey(n"Mod-Addicted-Threshold-Barely");
      case Threshold.Clean:
        return GetLocalizedTextByKey(n"Mod-Addicted-Threshold-Clean");
    }
  }

  public static func BiomonitorStatus(threshold: Threshold) -> String {
    switch (threshold) {
      case Threshold.Severely:
        return GetLocalizedTextByKey(n"Mod-Addicted-Biomonitor-Status-Threshold-Severely");
      default:
        break;
    }
    return GetLocalizedTextByKey(n"Mod-Addicted-Biomonitor-Status-Threshold-Notably");
  }

  public static func Appellation(id: TweakDBID) -> String {
    if Generic.IsMaxDOC(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MaxDOC");
    }
    if Generic.IsBounceBack(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BounceBack");
    }
    if Generic.IsHealthBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-HealthBooster");
    }
    if Generic.IsBlackLace(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BlackLace");
    }
    if Generic.IsStaminaBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-StaminaBooster");
    }
    if Generic.IsCapacityBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-CarryCapacityBooster");
    }
    if Generic.IsMemoryBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MemoryBooster");
    }
    return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-Unknown");
  }

  public static func ChemicalKey(consumable: Consumable) -> array<CName> {
    if Equals(EnumInt(consumable), EnumInt(Consumable.Invalid)) { return []; }
    switch(consumable) {
      case Consumable.Alcohol:
        return [n"Mod-Addicted-Chemical-Ethanol"];
      case Consumable.MaxDOC:
        return [];
      case Consumable.BounceBack:
        return [];
      case Consumable.HealthBooster:
        return [];
      case Consumable.MemoryBooster:
        return [n"Mod-Addicted-Chemical-Benzedrine", n"Mod-Addicted-Chemical-Modafinil"];
      case Consumable.OxyBooster:
        return [n"Mod-Addicted-Chemical-Trimix"];
      case Consumable.StaminaBooster:
        return [n"Mod-Addicted-Chemical-Cortisone", n"Mod-Addicted-Chemical-Hydrocortisone", n"Mod-Addicted-Chemical-Prednisone"];
      case Consumable.BlackLace:
        return [n"Mod-Addicted-Chemical-Dynorphin", n"Mod-Addicted-Chemical-Methadone"];
      case Consumable.CarryCapacityBooster:
        return [n"Mod-Addicted-Chemical-Testosterone", n"Mod-Addicted-Chemical-Oxandrin"];
    }
  }

  public static func SubtitleKey(mood: String, language: String) -> String {
    let suffix: String;
    if StrBeginsWith(mood, "addicted." + language + ".fem_v_") {
      suffix = StrAfterFirst(mood, "addicted." + language + ".fem_v_");
      return "Addicted-Voice-Subtitle-" + suffix;
    }
    if StrBeginsWith(mood, "addicted." + language + ".male_v_") {
      suffix = StrAfterFirst(mood, "addicted." + language + ".male_v_");
      return "Addicted-Voice-Subtitle-" + suffix;
    }
    return "";
  }
}