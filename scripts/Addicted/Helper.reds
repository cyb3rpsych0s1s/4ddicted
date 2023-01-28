module Addicted

import Addicted.*
import Addicted.Utils.{E,EI}
import Addicted.Helpers.*

public class Helper {
  public static func Category(id: TweakDBID) -> Category {
    if Generic.IsBlackLace(id) { return Category.Hard; }
    return Category.Mild;
  }

  public static func Potency(id: TweakDBID) -> Int32 {
    let category = Helper.Category(id);
    switch(category) {
      case Category.Hard:
        return 2;
      default:
        break;
    }
    return 1;
  }

  public static func Resilience(id: TweakDBID) -> Int32 {
    let category = Helper.Category(id);
    switch(category) {
      case Category.Hard:
        return 1;
      default:
        break;
    }
    return 2;
  }

  public static func Threshold(score: Int32) -> Threshold {
    if score == 0 { return Threshold.Clean; }
    if score > EnumInt(Threshold.Severely) {
      return Threshold.Severely;
    }
    if score > EnumInt(Threshold.Notably) {
      return Threshold.Notably;
    }
    if score > EnumInt(Threshold.Mildly) {
      return Threshold.Mildly;
    }
    return Threshold.Barely;
  }

  public static func IsApplied(effects: array<ref<StatusEffect>>, id: TweakDBID) -> Bool {
    for effect in effects {
      if Equals(effect.GetRecord().GetID(), id) {
        return true;
      }
    }
    return false;
  }

  public static func AreApplied(effects: array<ref<StatusEffect>>, ids: array<TweakDBID>) -> Bool {
    let contains: Bool;
    for effect in effects {
      contains = ArrayContains(ids, effect.GetRecord().GetID());
      if contains {
        return true;
      }
    }
    return false;
  }

  public static func Consumables(addiction: Addiction) -> array<Consumable> {
    switch(addiction) {
      case Addiction.Healers:
        return [Consumable.BounceBack, Consumable.MaxDOC, Consumable.HealthBooster];
      case Addiction.Anabolics:
        return [Consumable.StaminaBooster, Consumable.CarryCapacityBooster];
      case Addiction.Neuros:
        return [Consumable.MemoryBooster];
      default:
        break;
    }
    return [];
  }

  public static func Consumables() -> array<Consumable> {
    return [
      Consumable.Alcohol,
      Consumable.MaxDOC,
      Consumable.BounceBack,
      Consumable.HealthBooster,
      Consumable.MemoryBooster,
      Consumable.OxyBooster,
      Consumable.StaminaBooster,
      Consumable.BlackLace,
      Consumable.CarryCapacityBooster
    ];
  }

  // all related drugs (as general items name) for a given addiction
  public static func Drugs(addiction: Addiction) -> array<TweakDBID> {
    switch (addiction) {
      case Addiction.Healers:
        return [
          t"Items.FirstAidWhiffV0",
          t"Items.FirstAidWhiffV1",
          t"Items.FirstAidWhiffV2",
          t"Items.BonesMcCoy70V0",
          t"Items.BonesMcCoy70V1",
          t"Items.BonesMcCoy70V2",
          t"Items.HealthBooster"
        ];
      default:
        break;
    }
    return [];
  }

  public static func Effects(consumable: Consumable) -> array<TweakDBID> {
    switch (consumable) {
      case Consumable.Alcohol:
        return [t"BaseStatusEffect.AlcoholDebuff"];
      case Consumable.MaxDOC:
        return Helper.EffectsByName("FirstAidWhiff");
      case Consumable.BounceBack:
        return Helper.EffectsByName("BonesMcCoy70");
      case Consumable.HealthBooster:
        return Helper.EffectsByName("HealthBooster");
      case Consumable.MemoryBooster:
        return [t"BaseStatusEffect.MemoryBooster"];
      case Consumable.OxyBooster:
        return [t"BaseStatusEffect.OxyBooster"];
      case Consumable.StaminaBooster:
        return [t"BaseStatusEffect.StaminaBooster"];
      case Consumable.BlackLace:
        return [t"BaseStatusEffect.BlackLaceV0"];
      default:
        break;
    }
    return [];
  }

  private static func EffectsByName(name: String) -> array<TweakDBID> {
    let records = TweakDBInterface.GetRecords(n"StatusEffect_Record");
    let out: array<TweakDBID> = [];
    let id: TweakDBID;
    let str: String;
    for record in records {
      id = (record as StatusEffect_Record).GetID();
      str = TDBID.ToStringDEBUG(id);
      if StrBeginsWith(str, "BaseStatusEffect") && StrContains(str, name) {
        ArrayPush(out, id);
      }
    }
    return out;
  }

  public static func Addictions() -> array<Addiction> {
    return [
      Addiction.Healers,
      Addiction.Anabolics,
      Addiction.Neuros
    ];
  }

  public static func IsSerious(threshold: Threshold) -> Bool {
    return EnumInt(threshold) == EnumInt(Threshold.Notably) || EnumInt(threshold) == EnumInt(Threshold.Severely);
  }

  public static func Biomonitors() -> array<TweakDBID> {
    return [
      t"Items.HealthMonitorCommon",
      t"Items.HealthMonitorUncommon",
      t"Items.HealthMonitorRare",
      t"Items.HealthMonitorEpic",
      t"Items.HealthMonitorLegendary"
    ];
  }

  public static func IsSleep(id: TweakDBID) -> Bool { return Equals(id, t"HousingStatusEffect.Rested"); }

  public static func AppropriateHintRequest(id: TweakDBID, threshold: Threshold, now: Float) -> ref<HintRequest> {
    if Helper.IsSerious(threshold) {
      let request: ref<HintRequest>;
      if Generic.IsInhaler(id) {
        request = new CoughingRequest();
      }
      // anabolic are also pills, but the opposite isn't true
      let anabolic = Generic.IsAnabolic(id);
      let pill = Generic.IsPill(id);
      if anabolic || pill {
        let random = RandRangeF(1, 10);
        let above: Bool;
        if Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) {
          above = random >= 7.;
        } else {
          above = random >= 9.;
        }
        if anabolic {
          if above {
            request = new VomitingRequest();
          }
          request = new BreatheringRequest();
        } else {
          if above {
            request = new VomitingRequest();
          }
          request = new HeadAchingRequest();
        }
      }
      if Generic.IsInjector(id) {
        request = new AchingRequest();
      }
      request.threshold = threshold;
      let randtime = request.RandTime();
      request.until = now + request.RandTime();
      request.times = request.InitialTimes();
      E(s"packing appropriate request: until \(ToString(request.until)) (randtime \(ToString(randtime))), \(ToString(request.times)) time(s), threshold \(ToString(request.threshold)) (\(TDBID.ToStringDEBUG(id)))");
      return request;
    }
    return null;
  }

  public static func GetTranslation(threshold: Threshold) -> String {
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

  public static func Lower(threshold: Threshold) -> Threshold {
    switch(threshold) {
      case Threshold.Severely:
        return Threshold.Notably;
      case Threshold.Notably:
        return Threshold.Mildly;
      case Threshold.Mildly:
        return Threshold.Barely;
      default:
        return Threshold.Clean;
    }
  }

  public static func Higher(threshold: Threshold) -> Threshold {
    switch(threshold) {
      case Threshold.Clean:
        return Threshold.Barely;
      case Threshold.Barely:
        return Threshold.Mildly;
      case Threshold.Mildly:
        return Threshold.Notably;
      default:
        return Threshold.Severely;
    }
  }

  public static final func MakeGameTime(timestamp: Float) -> GameTime {
    timestamp = Cast<Float>(RoundF(timestamp));
    let days: Float = timestamp / 86400.;
    let hours: Float = (timestamp % 86400.) / 3600.;
    let minutes: Float = ((timestamp % 86400.) % 3600.) / 60.;
    let seconds: Float = (((timestamp % 86400.) % 3600.) % 60.) / 60.;
    let time = GameTime.MakeGameTime(RoundF(days), RoundF(hours), RoundF(minutes), RoundF(seconds));
    return time;
  }
}
