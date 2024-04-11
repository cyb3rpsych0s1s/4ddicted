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

  public static func Appellation(consumable: Consumable) -> String {
    switch consumable {
      case Consumable.Alcohol:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-Alcohol");
      case Consumable.MaxDOC:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MaxDOC");
      case Consumable.BounceBack:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BounceBack");
      case Consumable.HealthBooster:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-HealthBooster");
      case Consumable.MemoryBooster:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-MemoryBooster");
      case Consumable.StaminaBooster:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-StaminaBooster");
      case Consumable.CarryCapacityBooster:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-CarryCapacityBooster");
      case Consumable.BlackLace:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-BlackLace");
      case Consumable.NeuroBlocker:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-NeuroBlocker");
      case Consumable.Tobacco:
        return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-Tobacco");
      default:
        break;
    }
    return GetLocalizedTextByKey(n"Mod-Addicted-Consumable-Unknown");
  }

  public static func ChemicalKey(consumable: Consumable) -> array<CName> {
    if Equals(EnumInt(consumable), EnumInt(Consumable.Invalid)) { return []; }
    switch(consumable) {
      case Consumable.Alcohol:
        return [n"Mod-Addicted-Chemical-Ethanol"];
      case Consumable.MaxDOC:
        return [n"Mod-Addicted-Chemical-Epinephrine", n"Mod-Addicted-Chemical-Paracetamol", n"Mod-Addicted-Chemical-Nanites"];
      case Consumable.BounceBack:
        return [n"Mod-Addicted-Chemical-Epinephrine", n"Mod-Addicted-Chemical-Paracetamol", n"Mod-Addicted-Chemical-Nanites"];
      case Consumable.HealthBooster:
        return [n"Mod-Addicted-Chemical-Epinephrine", n"Mod-Addicted-Chemical-Paracetamol", n"Mod-Addicted-Chemical-Nanites"];
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
      case Consumable.Tobacco:
        return [n"Mod-Addicted-Chemical-Nicotine"];
    }
  }
}