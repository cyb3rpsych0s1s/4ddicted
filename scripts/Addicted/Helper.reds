module Addicted

import Addicted.*
import Addicted.Utils.{E,EI}
import Addicted.Helpers.*

public func IsLanguageSupported(locale: CName) -> Bool {
  return Equals(locale, n"en-us")
  || Equals(locale, n"fr-fr")
  || Equals(locale, n"es-es")
  || Equals(locale, n"zh-cn")
  || Equals(locale, n"pt-br")
  || Equals(locale, n"it-it");
}

public class Helper {
  public static func Category(id: ItemID) -> Category {
    if Generic.IsBlackLace(ItemID.GetTDBID(id))
    || Generic.IsAlcohol(ItemID.GetTDBID(id)) { return Category.Hard; }
    return Category.Mild;
  }

  public static func Potency(id: ItemID) -> Int32 {
    let category = Helper.Category(id);
    switch(category) {
      case Category.Hard:
        return 2;
      default:
        break;
    }
    return 1;
  }

  public static func Resilience(id: ItemID) -> Int32 {
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
      hint.threshold = threshold;
      let randtime = hint.RandTime();
      hint.until = now + randtime;
      hint.times = hint.InitialTimes();
      E(s"packing appropriate hint: until \(ToString(hint.until)) (randtime \(ToString(randtime))), \(ToString(hint.times)) time(s), threshold \(ToString(hint.threshold)) (\(TDBID.ToStringDEBUG(id)))");
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
