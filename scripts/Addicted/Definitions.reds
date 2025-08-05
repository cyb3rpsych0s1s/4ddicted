module Addicted

import Addicted.Helper
import Addicted.Helpers.{Generic,Translations}
import Addicted.Utils.E

public abstract class Hint {
  // game timestamp where to stop at
  protected let until: Float;
  protected let times: Int32;
  protected let threshold: Threshold;
  protected let onomatopea: Onomatopea;
  public func Sound() -> CName;
  public func Onomatopea() -> Onomatopea;
  public func IsLoop() -> Bool { return false; }
  public func Duration() -> Float { return 5.; }
  public func InitialTimes() -> Int32 {
    if this.IsLoop() { return 1; }
    if Equals(EnumInt(this.threshold), EnumInt(Threshold.Severely)) {
      return 3;
    }
    return 1;
  }
  public func AtMost() -> Float {
    if this.IsLoop() { return 1.; }
    if Equals(EnumInt(this.threshold), EnumInt(Threshold.Severely)) {
      return 5.;
    }
    return 3.;
  }
  public func RandTime() -> Float {
    let consumeTime = 3.;
    let playTime = this.Duration() * this.AtMost();
    let gapTime = (this.AtMost() - 1.) * 2.;
    let least = consumeTime + playTime + gapTime;
    let most = least * 2.;
    let delay = RandRangeF(least, most);
    return delay;
  }
  public func GetThreshold() -> Threshold = this.threshold;
  public func SetThreshold(value: Threshold) -> Void {
    this.threshold = value;
  }
  public func GetUntil() -> Float = this.until;
  public func SetUntil(value: Float) -> Void {
    this.until = value;
  }
  public func GetTimes() -> Int32 = this.times;
  public func SetTimes(value: Int32) -> Void {
    this.times = value;
  }
}

// hint for inhalers
public class CoughingHint extends Hint {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Cough; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"g_sc_v_sickness_cough_hard";
    }
    return n"g_sc_v_sickness_cough_light";
  }
}
// hint for pills
public class VomitingHint extends Hint {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Vomit; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"g_sc_v_sickness_cough_blood";
    }
    return n"ono_v_choking";
  }
}
// hint for injectors
public class AchingHint extends Hint {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Ache; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"ono_v_pain_long";
    }
    return n"ono_v_pain_short";
  }
}
// hint for anabolics
public class BreatheringHint extends Hint {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Breather; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"ono_v_effort_long";
    }
    return n"ono_v_effort_short";
  }
}
// hint for memory booster
public class HeadAchingHint extends Hint {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Headache; }
  public func Sound() -> CName {
    return n"q101_sc_03_heart_loop";
  }
  public func IsLoop() -> Bool { return true; }
  public func Duration() -> Float {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return 90.;
    }
    return 45.;
  }
}

public class Consumptions {
  private persistent let keys: array<TweakDBID>;
  private persistent let values: array<ref<Consumption>>;

  public func Insert(id: ItemID, value: ref<Consumption>) -> Void {
    let key: TweakDBID;
    if this.KeyExist(id) { return; }
    key = ItemID.GetTDBID(id);
    ArrayPush(this.values, value);
    ArrayPush(this.keys, key);
  }
  private func Index(id: ItemID) -> Int32 {
    let key = ItemID.GetTDBID(id);
    let idx = 0;
    let found = false;
    for existing in this.keys {
      if existing == key {
        found = true;
        break;
      }
      idx += 1;
    }
    if found {
      return idx;
    }
    return -1;
  }
  public func Get(id: ItemID) -> ref<Consumption> {
    let idx = this.Index(id);
    if idx == -1 { return null; }
    return this.values[idx];
  }
  public func KeyExist(id: ItemID) -> Bool {
    let idx = this.Index(id);
    return idx != -1;
  }
  public func Remove(id: ItemID) -> Void {
    let idx = this.Index(id);
    if idx == -1 { return; }
    ArrayErase(this.keys, idx);
    ArrayErase(this.values, idx);
  }
  public func Clear() -> Void {
    ArrayClear(this.keys);
    ArrayClear(this.values);
  }
  public func Size() -> Int32 {
    let size = ArraySize(this.keys);
    return size;
  }
  public func Keys() -> array<TweakDBID> {
    return this.keys;
  }
  public func Items() -> array<ItemID> {
    let items: array<ItemID> = [];
    for key in this.keys {
      ArrayPush(items, ItemID.FromTDBID(key));
    }
    return items;
  }
  private func Consumptions(consumable: Consumable) -> array<ref<Consumption>> {
    let ids = this.Items();
    let compared: Consumable;
    let consumption: ref<Consumption>;
    let out: array<ref<Consumption>> = [];
    for id in ids {
      compared = Generic.Consumable(ItemID.GetTDBID(id));
      if Equals(compared, consumable) {
        consumption = this.Get(id);
        ArrayPush(out, consumption);
      }
    }
    return out;
  }
  public func LastDose(consumable: Consumable) -> Float {
    let consumptions = this.Consumptions(consumable);
    let last: Float = -1.0;
    let current: Float;
    for consumption in consumptions {
      current = consumption.LastDose();
      if NotEquals(current, -1.0) && current > last {
        last = current;
      }
    }
    return last;
  }
  public func LastDose(addiction: Addiction) -> Float {
    let consumables = Helper.Consumables(addiction);
    let last: Float = -1.0;
    let current: Float;
    for consumable in consumables {
      current = this.LastDose(consumable);
      if NotEquals(current, -1.0) && current > last {
        last = current;
      }
    }
    return last;
  }
  public func Threshold(id: ItemID) -> Threshold {
    let consumption = this.Get(id);
    if IsDefined(consumption) {
      return consumption.Threshold();
    }
    return Threshold.Clean;
  }
  public func Threshold(consumable: Consumable) -> Threshold {
    let total = this.TotalConsumption(consumable);
    return Helper.Threshold(total);
  }
  public func Threshold(addiction: Addiction) -> Threshold {
    let average = this.AverageConsumption(addiction);
    return Helper.Threshold(average);
  }
  public func HighestThreshold() -> Threshold {
    let variants = Consumables();
    let highest: Threshold = Threshold.Clean;
    let current: Threshold;
    for variant in variants {
      current = this.Threshold(variant);
      if EnumInt(current) > EnumInt(highest) {
        highest = current;
      }
    }
    return highest;
  }
  public func HighestThreshold(addiction: Addiction) -> Threshold {
    let consumables = Helper.Consumables(addiction);
    let highest: Threshold = Threshold.Clean;
    let current: Threshold;
    for consumable in consumables {
      current = this.Threshold(consumable);
      if EnumInt(current) > EnumInt(highest) {
        highest = current;
      }
    }
    return highest;
  }
  /// total consumption for a given consumable
  /// each consumable can have one or many versions (e.g maxdoc and bounceback have 3+ versions each)
  public func TotalConsumption(consumable: Consumable) -> Int32 {
    let total = 0;
    let consumptions = this.Consumptions(consumable);
    for consumption in consumptions {
      total += consumption.current;
    }
    return total;
  }
  /// average consumption for an addiction
  /// a single addiction can be shared by multiple consumables
  public func AverageConsumption(addiction: Addiction) -> Int32 {
    let consumables = Helper.Consumables(addiction);
    let size = ArraySize(consumables);
    let total = 0;
    for consumable in consumables {
      total += this.TotalConsumption(consumable);
    }
    return total / size;
  }
  /// symptoms for biomonitor
  public func Symptoms() -> array<ref<Symptom>> {
    let consumables: array<Consumable> = Consumables();
    let symptoms: array<ref<Symptom>> = [];
    let symptom: ref<Symptom>;
    let threshold: Threshold;
    for consumable in consumables {
      threshold = this.Threshold(consumable);
      if Helper.IsSerious(threshold) {
        symptom = new Symptom();
        symptom.Title = Translations.Appellation(consumable);
        symptom.Status = Translations.BiomonitorStatus(threshold);
        ArrayPush(symptoms, symptom);
      }
    }
    return symptoms;
  }
  /// chemicals for biomonitor
  public func Chemicals() -> array<ref<Chemical>> {
    let consumables = Consumables();
    let chemicals: array<ref<Chemical>> = [];
    let chemical: ref<Chemical>;
    let translations: array<CName>;
    let threshold: Threshold;
    let max: Int32 = 7;
    let found: Int32 = 0;
    let duplicate: Bool;
    // here logic is not accurate since you could end up with not the highest threshold
    // for consumables which share the same chemicals composition
    // but it's not really important in terms of gameplay
    for consumable in consumables {
      threshold = this.Threshold(consumable);
      if Helper.IsSerious(threshold) {
        translations = Translations.ChemicalKey(consumable);
        for translation in translations {
          duplicate = Contains(chemicals, translation);
          if !duplicate {
            chemical = new Chemical();
            chemical.Key = translation;
            chemical.From = (Cast<Float>(EnumInt(threshold)) / 2.0) + RandRangeF(-10.0, 10.0);
            chemical.To = Cast<Float>(EnumInt(threshold)) + RandRangeF(-10.0, 10.0);
            ArrayPush(chemicals, chemical);
            found += 1;
            if found == max { return chemicals; }
          }
        }
      }
    }
    return chemicals;
  }
}

public func Contains(chemicals: array<ref<Chemical>>, translation: CName) -> Bool {
  for chemical in chemicals {
    if Equals(chemical.Key, translation) { return true; }
  }
  return false;
}

public class Consumption {
  public persistent let current: Int32;
  public persistent let doses: array<Float>;

  public static func Create(amount: Int32, when: Float) -> ref<Consumption> {
    let consumption = new Consumption();
    consumption.current = amount;
    consumption.doses = [when];
    return consumption;
  }

  public func Threshold() -> Threshold {
    return Helper.Threshold(this.current);
  }

  public func LastDose() -> Float {
    let size = ArraySize(this.doses);
    if size == 0 { return -1.0; }
    let last = ArrayLast(this.doses);
    return last;
  }
}

public enum Onomatopea {
  Cough = 0,
  Headache = 1,
  Breather = 2,
  Ache = 3,
  Vomit = 4,
}

public enum Category {
  Mild = 0,
  Hard = 1,
}

/// addiction thresholds
public enum Threshold {
  Clean = 0,
  Barely = 10,
  Mildly = 20,
  Notably = 40,
  Severely = 60,
}

public enum Consumable {
  Invalid = -1,
  Alcohol = 1,
  MaxDOC = 2, // FirstAidWhiff
  BounceBack = 3, // BonesMcCoy
  HealthBooster = 4,
  MemoryBooster = 5,
  OxyBooster = 6,
  StaminaBooster = 7,
  BlackLace = 8,
  CarryCapacityBooster = 9,
  NeuroBlocker = 10,
  Tobacco = 11
}

public func Consumables() -> array<Consumable> {
  return [
    Consumable.Alcohol,
    Consumable.MaxDOC,
    Consumable.BounceBack,
    Consumable.HealthBooster,
    Consumable.MemoryBooster,
    Consumable.OxyBooster,
    Consumable.StaminaBooster,
    Consumable.BlackLace,
    Consumable.CarryCapacityBooster,
    Consumable.NeuroBlocker,
    Consumable.Tobacco
  ];
}

public enum Kind {
  Inhaler = 0,
  Injector = 1,
  Pill = 2,
}

public enum Addiction {
  Invalid = -1,
  Healers = 0,
  Anabolics = 1,
  Neuros = 2,
  BlackLace = 3,
  Alcohol = 4,
  Tobacco = 5,
}

public func Addictions() -> array<Addiction> {
  return [
    Addiction.Healers,
    Addiction.Anabolics,
    Addiction.Neuros,
    Addiction.BlackLace,
    Addiction.Alcohol,
    Addiction.Tobacco
  ];
}

public enum PlaySoundPolicy {
  All = 0,
  AmbientOnly = 1,
}

public enum Mood {
  Any = 0,
  Disheartened = 1,
  Offhanded = 2,
  Pestered = 3,
  Surprised = 4,
}
