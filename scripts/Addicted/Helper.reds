module Addicted

import Addicted.*
import Addicted.Utils.{E,EI}
import Addicted.Helpers.*

public func IsLanguageSupported(locale: CName) -> Bool = Equals(locale, n"en-us")
|| Equals(locale, n"fr-fr") || Equals(locale, n"es-es") || Equals(locale, n"zh-cn") || Equals(locale, n"pt-br") || Equals(locale, n"it-it") || Equals(locale, n"kr-kr");

public class Helper {
  public static func Potency(id: ItemID, subsequentUse: Bool, modifier: Float) -> Int32 {
    let consumableName = Generic.Consumable(id);

    switch(consumableName) {
      case Consumable.Alcohol: 
      case Consumable.Tobacco: 
        return subsequentUse ? 1 : 4;
      case Consumable.BlackLace: 
        return subsequentUse ? 2 : 8;
      case Consumable.HealthBooster:
      case Consumable.StaminaBooster:
      case Consumable.OxyBooster:
      case Consumable.MemoryBooster:
        return subsequentUse ? 4 : 6;
      case Consumable.NeuroBlocker:
        return subsequentUse ? RoundMath(1. * modifier) : RoundMath(3. * modifier);
    }
    return subsequentUse ? 1 : 2;
  }

  public static func Resilience(id: ItemID, daysSinceLastConsumed: Int32) -> Int32 {
    let consumableName = Generic.Consumable(id);
    let resilienceModifier = Min(5, Max(1, daysSinceLastConsumed - 1)); 

    switch(consumableName) {
      case Consumable.BlackLace: 
      case Consumable.Alcohol: 
        return resilienceModifier * 1;
    }
    return resilienceModifier * 2;
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
        return [Consumable.MemoryBooster, Consumable.NeuroBlocker];
      case Addiction.BlackLace:
        return [Consumable.BlackLace];
      case Addiction.Alcohol:
        return [Consumable.Alcohol];
      case Addiction.Tobacco:
        return [Consumable.Tobacco];
      default:
        break;
    }
    return [];
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
      t"Items.HealthMonitorLegendary",
      t"Items.AdvancedBiomonitorCommon",
      t"Items.AdvancedBiomonitorCommonPlus",
      t"Items.AdvancedBiomonitorUncommon",
      t"Items.AdvancedBiomonitorUncommonPlus",
      t"Items.AdvancedBiomonitorRare",
      t"Items.AdvancedBiomonitorRarePlus",
      t"Items.AdvancedBiomonitorEpic",
      t"Items.AdvancedBiomonitorEpicPlus",
      t"Items.AdvancedBiomonitorLegendary",
      t"Items.AdvancedBiomonitorLegendaryPlus",
      t"Items.AdvancedBiomonitorLegendaryPlusPlus"
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
      hint.SetThreshold(threshold);
      let randtime = hint.RandTime();
      hint.SetUntil(now + randtime);
      hint.SetTimes(hint.InitialTimes());
      E(s"packing appropriate hint: until \(ToString(hint.GetUntil())) (randtime \(ToString(randtime))), \(ToString(hint.GetTimes())) time(s), threshold \(ToString(hint.GetThreshold())) (\(TDBID.ToStringDEBUG(id)))");
      return hint;
    }
    return null;
  }

  public static func OnceWarned(gender: gamedataGender, threshold: Threshold, warnings: Uint32, language: CName) -> CName {
    let reaction: CName;
    let odds: Float = 1.0;
    let female: Bool = Equals(gender, gamedataGender.Female);
    let onos: array<CName> = [
      n"ono_v_greet",
      n"ono_v_curious",
      female ? StringToName("addicted." + NameToString(language) + ".fem_v_ono_hhuh") : StringToName("addicted." + NameToString(language) + ".male_v_ono_hhuh"),
      female ? StringToName("addicted." + NameToString(language) + ".fem_v_ono_huh")  : StringToName("addicted." + NameToString(language) + ".male_v_ono_huh"),
      female ? StringToName("addicted." + NameToString(language) + ".fem_v_ono_huhuh"): StringToName("addicted." + NameToString(language) + ".male_v_ono_huhuh")
    ];
    let random = RandF();
    if warnings >= 5u { odds -= 0.2; } // cumulative
    if warnings >= 3u { odds -= 0.3; } // cumulative
    if EnumInt(threshold) >= EnumInt(Threshold.Severely) { odds -= 0.1; } // cumulative
    if EnumInt(threshold) >= EnumInt(Threshold.Notably) { odds -= 0.3; } // cumulative
    E(s"once warned => random: \(random) > odds: \(odds)");
    if random > odds {
      let mood: Mood = Feeling.OnceWarned(threshold, warnings);
      reaction = Feeling.Reaction(mood, gender, language);
    } else {
      let choice: Int32 = RandRange(0, ArraySize(onos) -1);
      reaction = onos[choice];
    }
    E(s"picked reaction: \(NameToString(reaction))");
    return reaction;
  }

  public static func OnDismissInCombat(gender: gamedataGender, language: CName) -> CName {
    let mood: Mood = Feeling.OnDismissInCombat();
    
    let reaction = Feeling.Reaction(mood, gender, language);
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
        break;
    }
    return Threshold.Clean;
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
