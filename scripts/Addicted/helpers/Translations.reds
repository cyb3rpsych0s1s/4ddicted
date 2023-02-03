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
    let designation = Generic.Designation(id);
    switch (designation) {
      case "Items.FirstAidWhiffV0":
      case "Items.FirstAidWhiffV1":
      case "Items.FirstAidWhiffV2":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MaxDOC");
      case "Items.BonesMcCoy70V0":
      case "Items.BonesMcCoy70V1":
      case "Items.BonesMcCoy70V2":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BounceBack");
      case "Items.HealthBooster":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-HealthBooster");
      case "Items.BlackLaceV0":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BlackLace");
      case "Items.StaminaBooster":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-StaminaBooster");
      case "Items.CarryCapacityBooster":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-CarryCapacityBooster");
      case "Items.MemoryBooster":
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MemoryBooster");
      default:
        break;
    }
    return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-Unknown");
  }
}