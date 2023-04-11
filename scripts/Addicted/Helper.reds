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
      case Addiction.Anabolics:
        return [
          t"Items.StaminaBooster",
          t"Items.CarryCapacityBooster"
        ];
      case Addiction.Neuros:
        return [
          t"Items.MemoryBooster"
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
        return Helper.EffectsByName("BlackLace");
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

  public static func AppropriateHint(id: TweakDBID, threshold: Threshold, now: Float) -> ref<Hint> {
    if Helper.IsSerious(threshold) {
      let hint: ref<Hint>;
      if Generic.IsInhaler(id) {
        hint = new CoughingHint();
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
            hint = new VomitingHint();
          }
          hint = new BreatheringHint();
        } else {
          if above {
            hint = new VomitingHint();
          }
          hint = new HeadAchingHint();
        }
      }
      if Generic.IsInjector(id) {
        hint = new AchingHint();
      }
      hint.threshold = threshold;
      let randtime = hint.RandTime();
      hint.until = now + randtime;
      hint.times = hint.InitialTimes();
      E(s"packing appropriate hint: until \(ToString(hint.until)) (randtime \(ToString(randtime))), \(ToString(hint.times)) time(s), threshold \(ToString(hint.threshold)) (\(TDBID.ToStringDEBUG(id)))");
      return hint;
    }
    return null;
  }

  public static func OnceWarned(gender: gamedataGender, threshold: Threshold, warnings: Uint32) -> CName {
    let reaction: CName;
    let odds: Float = 1.0;
    let female: Bool = Equals(gender, gamedataGender.Female);
    let onos: array<CName> = [
      n"ono_v_greet",
      n"ono_v_curious",
      female ? n"addicted.en-us.fem_v_ono_hhuh" : n"addicted.en-us.male_v_ono_hhuh",
      female ? n"addicted.en-us.fem_v_ono_huh" : n"addicted.en-us.male_v_ono_huh",
      female ? n"addicted.en-us.fem_v_ono_huhuh" : n"addicted.en-us.male_v_ono_huhuh"
    ];
    let random = RandF();
    if warnings >= 5u { odds -= 0.2; } // cumulative
    if warnings >= 3u { odds -= 0.3; } // cumulative
    if EnumInt(threshold) >= EnumInt(Threshold.Severely) { odds -= 0.1; } // cumulative
    if EnumInt(threshold) >= EnumInt(Threshold.Notably) { odds -= 0.3; } // cumulative
    E(s"once warned => random: \(random) > odds: \(odds)");
    if random > odds {
      let mood: Mood = Feeling.OnceWarned(threshold, warnings);
      reaction = Feeling.Reaction(mood, gender);
    } else {
      let choice: Int32 = RandRange(0, ArraySize(onos) -1);
      reaction = onos[choice];
    }
    E(s"picked reaction: \(NameToString(reaction))");
    return reaction;
  }

  public static func OnDismissInCombat(gender: gamedataGender) -> CName {
    let mood: Mood = Feeling.OnDismissInCombat();
    let reaction = Feeling.Reaction(mood, gender);
    return reaction;
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
