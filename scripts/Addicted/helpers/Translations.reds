module Addicted.Helpers

import Addicted.*

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

  public static func Appellation(id: TweakDBID) -> String {
    if Helper.IsMaxDOC(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MaxDOC");
    }
    if Helper.IsBounceBack(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BounceBack");
    }
    if Helper.IsHealthBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-HealthBooster");
    }
    if Helper.IsBlackLace(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BlackLace");
    }
    if Helper.IsStaminaBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-StaminaBooster");
    }
    if Helper.IsCapacityBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-CarryCapacityBooster");
    }
    if Helper.IsMemoryBooster(id) {
      return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MemoryBooster");
    }
    return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-Unknown");
  }
}