module Addicted

import Addicted.Helper
import Addicted.Helpers.Generic

public abstract class HintRequest extends ScriptableSystemRequest {
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
public class CoughingRequest extends HintRequest {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Cough; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"g_sc_v_sickness_cough_hard";
    }
    return n"g_sc_v_sickness_cough_light";
  }
}
// hint for pills
public class VomitingRequest extends HintRequest {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Vomit; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"g_sc_v_sickness_cough_blood";
    }
    return n"ono_v_choking";
  }
}
// hint for injectors
public class AchingRequest extends HintRequest {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Ache; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"ono_v_pain_long";
    }
    return n"ono_v_pain_short";
  }
}
// hint for anabolics
public class BreatheringRequest extends HintRequest {
  public func Onomatopea() -> Onomatopea { return Onomatopea.Breather; }
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"ono_v_effort_long";
    }
    return n"ono_v_effort_short";
  }
}
// hint for memory booster
public class HeadAchingRequest extends HintRequest {
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

public class UpdateWithdrawalSymptomsRequest extends ScriptableSystemRequest {}

public class Consumptions {
  private persistent let keys: array<TweakDBID>;
  private persistent let values: array<ref<Consumption>>;

  public func Insert(key: TweakDBID, value: ref<Consumption>) -> Void {
    let base = Generic.ItemBaseName(key);
    if this.KeyExist(base) { return; }
    ArrayPush(this.values, value);
    ArrayPush(this.keys, base);
  }
  private func Index(key: TweakDBID) -> Int32 {
    let base = Generic.ItemBaseName(key);
    let idx = 0;
    let found = false;
    for existing in this.keys {
      if existing == base {
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
  public func Get(key: TweakDBID) -> ref<Consumption> {
    let idx = this.Index(key);
    if idx == -1 { return null; }
    return this.values[idx];
  }
  public func Set(key: TweakDBID, value: ref<Consumption>) -> Void {
    let idx = this.Index(key);
    if idx == -1 { return; }
    this.values[idx] = value;
  }
  public func KeyExist(key: TweakDBID) -> Bool {
    let idx = this.Index(key);
    return idx != -1;
  }
  public func Remove(key: TweakDBID) -> Void {
    let idx = this.Index(key);
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
  public func Threshold(key: TweakDBID) -> Threshold {
    let consumption = this.Get(key);
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
  Alcohol = 0,
  MaxDOC = 1, // FirstAidWhiff
  BounceBack = 2, // BonesMcCoy
  HealthBooster = 3,
  MemoryBooster = 4,
  OxyBooster = 5,
  StaminaBooster = 6,
  BlackLace = 7,
  CarryCapacityBooster = 8,
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
