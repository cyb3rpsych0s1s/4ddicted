module Addicted

import Addicted.Helper
import Addicted.Helpers.{Generic,Translations}

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

  public func Insert(id: TweakDBID, value: ref<Consumption>) -> Void {
    let key = Generic.Designation(id);
    if this.KeyExist(key) { return; }
    ArrayPush(this.values, value);
    ArrayPush(this.keys, key);
  }
  private func Index(id: TweakDBID) -> Int32 {
    let key = Generic.Designation(id);
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
  public func Get(id: TweakDBID) -> ref<Consumption> {
    let idx = this.Index(id);
    if idx == -1 { return null; }
    return this.values[idx];
  }
  public func Set(id: TweakDBID, value: ref<Consumption>) -> Void {
    let idx = this.Index(id);
    if idx == -1 { return; }
    this.values[idx] = value;
  }
  public func KeyExist(id: TweakDBID) -> Bool {
    let idx = this.Index(id);
    return idx != -1;
  }
  public func Remove(id: TweakDBID) -> Void {
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
  public func Threshold(id: TweakDBID) -> Threshold {
    let consumption = this.Get(id);
    if IsDefined(consumption) {
      return consumption.Threshold();
    }
    return Threshold.Clean;
  }
  public func Threshold(consumable: Consumable) -> Threshold {
    let average = this.AverageConsumption(consumable);
    return Helper.Threshold(average);
  }
  public func Threshold(addiction: Addiction) -> Threshold {
    let average = this.AverageConsumption(addiction);
    return Helper.Threshold(average);
  }
  public func HighestThreshold() -> Threshold {
    let consumption: ref<Consumption>;
    let keys = this.Keys();
    let current: Threshold = Threshold.Clean;
    let next: Threshold;
    for key in keys {
      consumption = this.Get(key);
      if IsDefined(consumption) {
        next = consumption.Threshold();
        if EnumInt(next) > EnumInt(current) {
          current = next;
          if Equals(EnumInt(current), EnumInt(Threshold.Severely)) { return current; }
        }
      }
    }
    return current;
  }
  /// average consumption for a given consumable
  /// each consumable can have one or many versions (e.g maxdoc and bounceback have 3 versions each)
  public func AverageConsumption(consumable: Consumable) -> Int32 {
    let ids = Helper.Effects(consumable);
    let total = 0;
    let found = 0;
    let consumption: wref<Consumption>;
    for id in ids {
      consumption = this.Get(id) as Consumption;
      if IsDefined(consumption) {
        total += consumption.current;
        found += 1;
      }
    }
    if found == 0 {
      return 0;
    }
    return total / found;
  }
  /// average consumption for an addiction
  /// a single addiction can be shared by multiple consumables
  public func AverageConsumption(addiction: Addiction) -> Int32 {
    let consumables = Helper.Consumables(addiction);
    let size = ArraySize(consumables);
    let total = 0;
    for consumable in consumables {
      total += this.AverageConsumption(consumable);
    }
    return total / size;
  }
  /// symptoms for biomonitor
  public func Symptoms() -> array<ref<Symptom>> {
    let symptoms: array<ref<Symptom>> = [];
    let symptom: ref<Symptom>;
    let consumption: ref<Consumption>;
    let threshold: Threshold;
    let keys = this.Keys();
    for key in keys {
      consumption = this.Get(key);
      if IsDefined(consumption) {
        threshold = consumption.Threshold();
        if Helper.IsSerious(threshold) {
            symptom = new Symptom();
            symptom.Title = Translations.Appellation(key);
            symptom.Status = Translations.BiomonitorStatus(threshold);
            ArrayPush(symptoms, symptom);
        }
      }
    }
    return symptoms;
  }
  /// chemicals for biomonitor
  public func Chemicals() -> array<ref<Chemical>> {
    let chemicals: array<ref<Chemical>> = [];
    let chemical: ref<Chemical>;
    let consumption: ref<Consumption>;
    let keys = this.Keys();
    let translations: array<CName>;
    let threshold: Threshold;
    let max: Int32 = 7;
    let found: Int32 = 0;
    for key in keys {
      consumption = this.Get(key);
      if IsDefined(consumption) {
        threshold = consumption.Threshold();
        if Helper.IsSerious(threshold) {
          translations = Translations.ChemicalKey(Generic.Consumable(key));
          for translation in translations {
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

public class Consumption {
  public persistent let current: Int32;
  public persistent let doses: array<Float>;

  public static func Create(id: TweakDBID, amount: Int32, when: Float) -> ref<Consumption> {
    let consumption = new Consumption();
    consumption.current = amount;
    consumption.doses = [when];
    return consumption;
  }

  public func Threshold() -> Threshold {
    return Helper.Threshold(this.current);
  }
}

enum Onomatopea {
  Cough = 0,
  Headache = 1,
  Breather = 2,
  Ache = 3,
  Vomit = 4,
}

enum Category {
  Mild = 0,
  Hard = 1,
}

/// addiction thresholds
enum Threshold {
  Clean = 0,
  Barely = 10,
  Mildly = 20,
  Notably = 40,
  Severely = 60,
}

enum Consumable {
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
}

enum Kind {
  Inhaler = 0,
  Injector = 1,
  Pill = 2,
}

enum Addiction {
  Healers = 0,
  Anabolics = 1,
  Neuros = 2,
}

enum PlaySoundPolicy {
  All = 0,
  AmbientOnly = 1,
}

enum Mood {
  Any = 0,
  Disheartened = 1,
  Offhanded = 2,
  Pestered = 3,
  Surprised = 4,
}
