module Addicted

import Addicted.*
import Addicted.Utils.{E,EI}

public class Helper {
  public static func Category(id: TweakDBID) -> Category {
    if Helper.IsBlackLace(id) { return Category.Hard; }
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

  public static func IsHealer(id: TweakDBID) -> Bool {
    return Helper.IsMaxDOC(id) || Helper.IsBounceBack(id) || Helper.IsHealthBooster(id);
  }

  public static func IsBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    return StrBeginsWith(str, "BaseStatusEffect") && StrContains(str, "Booster");
  }

  public static func IsInhaler(id: TweakDBID) -> Bool {
    return Helper.IsMaxDOC(id) || Helper.IsBlackLace(id);
  }

  public static func IsInjector(id: TweakDBID) -> Bool {
    return Helper.IsBounceBack(id);
  }

  public static func IsPill(id: TweakDBID) -> Bool {
    return Helper.IsCapacityBooster(id) ||
    Helper.IsStaminaBooster(id) ||
    Helper.IsMemoryBooster(id);
  }

  public static func IsAnabolic(id: TweakDBID) -> Bool {
    return Helper.IsCapacityBooster(id) || Helper.IsStaminaBooster(id);
  }

  public static func IsHealerAction(id: TweakDBID) -> Bool {
    return Helper.IsMaxDOC(id) || Helper.IsBounceBack(id) || Helper.IsHealthBooster(id);
  }

  public static func IsBoosterAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    return StrBeginsWith(str, "Items") && StrContains(str, "Booster");
  }

  public static func IsInhalerAction(id: TweakDBID) -> Bool {
    return Helper.IsMaxDOCAction(id) || Helper.IsBlackLaceAction(id);
  }

  public static func IsInjectorAction(id: TweakDBID) -> Bool {
    return Helper.IsBounceBackAction(id);
  }

  public static func IsPillAction(id: TweakDBID) -> Bool {
    return Helper.IsCapacityBooster(id) ||
    Helper.IsStaminaBoosterAction(id) ||
    Helper.IsMemoryBoosterAction(id);
  }

  public static func IsAnabolicAction(id: TweakDBID) -> Bool {
    return Helper.IsCapacityBoosterAction(id) || Helper.IsStaminaBoosterAction(id);
  }

  public static func IsInstant(id: TweakDBID) -> Bool {
    let effect = TweakDBInterface.GetRecord(id);
    if effect.IsA(n"gamedataStatusEffect_Record") {
      let status = effect as StatusEffect_Record;
      let duration: wref<StatModifierGroup_Record> = status.Duration();
      let records: array<wref<StatModifier_Record>>;
      let stat: wref<Stat_Record>;
      let rtype: CName;
      let modifier: wref<ConstantStatModifier_Record>;
      let value: Float;
      duration.StatModifiers(records);
      for record in records {
        stat = record.StatType();
        rtype = record.ModifierType();
        if Equals(stat.GetID(), t"BaseStats.MaxDuration") && Equals(rtype, n"Additive") && record.IsA(n"gamedataConstantStatModifier_Record") {
          modifier = record as ConstantStatModifier_Record;
          value = modifier.Value();
          return value < 1.;
        }
      }
    }
    return false;
  }

  public static func Consumable(id: TweakDBID) -> Consumable {
    if Helper.IsMaxDOC(id) { return Consumable.MaxDOC; }
    if Helper.IsBounceBack(id) { return Consumable.BounceBack; }
    if Helper.IsHealthBooster(id) { return Consumable.HealthBooster; }
    switch(id) {
      case t"BaseStatusEffect.AlcoholDebuff":
        return Consumable.Alcohol;
      case t"BaseStatusEffect.MemoryBooster":
        return Consumable.MemoryBooster;
      case t"BaseStatusEffect.OxyBooster":
        return Consumable.OxyBooster;
      case t"BaseStatusEffect.StaminaBooster":
        return Consumable.StaminaBooster;
      case t"BaseStatusEffect.BlackLaceV0":
        return Consumable.BlackLace;
      default:
        break;
    }
    return Consumable.Invalid;
  }

  public static func Consumables(addiction: Addiction) -> array<Consumable> {
    switch(addiction) {
      case Addiction.Healers:
        return [Consumable.BounceBack, Consumable.MaxDOC, Consumable.HealthBooster];
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

  public static func ActionEffect(id: TweakDBID, threshold: Threshold) -> TweakDBID {
    E(s"action effect for \(TDBID.ToStringDEBUG(id))");
    let serious = Helper.IsSerious(threshold);
    if !serious {
      return id;
    }
    let severe = EnumInt(threshold) == EnumInt(Threshold.Severely);
    if Helper.IsMaxDOC(id) {
      let version = Helper.RateMaxDOCAction(id);
      switch(version) {
        case 0:
          if severe {
            return t"Items.SeverelyWeakenedActionEffectFirstAidWhiffV0";
          }
          return t"Items.NotablyWeakenedActionEffectFirstAidWhiffV0";
        case 1:
          if severe {
            return t"Items.SeverelyWeakenedActionEffectFirstAidWhiffV1";
          }
          return t"Items.NotablyWeakenedActionEffectFirstAidWhiffV1";
        case 2:
          if severe {
            return t"Items.SeverelyWeakenedActionEffectFirstAidWhiffV2";
          }
          return t"Items.NotablyWeakenedActionEffectFirstAidWhiffV2";
        default:
          return id;
      }
    }
    if Helper.IsBounceBack(id) {
      let version = Helper.RateBounceBackAction(id);
      switch(version) {
        case 0:
          if severe {
            return t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V0";
          }
          return t"Items.NotablyWeakenedActionEffectBonesMcCoy70V0";
        case 1:
          if severe {
            return t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V1";
          }
          return t"Items.NotablyWeakenedActionEffectBonesMcCoy70V1";
        case 2:
          if severe {
            return t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V2";
          }
          return t"Items.NotablyWeakenedActionEffectBonesMcCoy70V2";
        default:
          return id;
      }
    }
    if Helper.IsHealthBooster(id) {
      if severe {
        return t"Items.SeverelyWeakenedActionEffectHealthBooster";
      }
      return t"Items.NotablyWeakenedActionEffectHealthBooster";
    }
    return id;
  }

  public static func IsAddictive(id: TweakDBID) -> Bool {
    // t"BaseStatusEffect.CombatStim" double-check
    return Helper.IsAlcohol(id) ||
    Helper.IsInhaler(id) ||
    Helper.IsBooster(id) ||
    Helper.IsInjector(id) ||
    Helper.IsHealthBooster(id);
  }

  public static func IsSerious(threshold: Threshold) -> Bool {
    return EnumInt(threshold) == EnumInt(Threshold.Notably) || EnumInt(threshold) == EnumInt(Threshold.Severely);
  }

  public static func IsHousing(id: TweakDBID) -> Bool {
    switch(id) {
      case t"HousingStatusEffect.Rested":
      case t"HousingStatusEffect.Refreshed":
      case t"HousingStatusEffect.Energized":
        return true;
      default:
        break;
    }
    return false;
  }

  public static func IsAlcohol(id: TweakDBID) -> Bool {
    return Equals(id, t"AlcoholDebuff");
  }

  public static func IsMaxDOC(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "BaseStatusEffect") && StrContains(str, "FirstAidWhiff") { return true; }
    return Helper.IsMaxDOCAction(id);
  }

  public static func IsBounceBack(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "BaseStatusEffect") && StrContains(str, "BonesMcCoy70") { return true; }
    return Helper.IsBounceBackAction(id);
  }

  public static func IsHealthBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "BaseStatusEffect") && StrContains(str, "HealthBooster") { return true; }
    return Helper.IsHealthBoosterAction(id);
  }

  public static func IsBlackLace(id: TweakDBID) -> Bool {
    return Equals(id, t"BaseStatusEffect.BlackLaceV0") || Equals(id, t"BaseStatusEffect.BlackLace");
  }

  public static func IsCapacityBooster(id: TweakDBID) -> Bool {
    return Equals(id, t"BaseStatusEffect.CarryCapacityBooster");
  }

  public static func IsStaminaBooster(id: TweakDBID) -> Bool {
    return Equals(id, t"BaseStatusEffect.StaminaBooster");
  }

  public static func IsMemoryBooster(id: TweakDBID) -> Bool {
    return Equals(id, t"BaseStatusEffect.MemoryBooster");
  }

  public static func IsOxyBooster(id: TweakDBID) -> Bool {
    return Equals(id, t"BaseStatusEffect.OxyBooster");
  }

  private static func IsMaxDOCAction(id: TweakDBID) -> Bool {
    let rate = Helper.RateMaxDOCAction(id);
    return rate != -1;
  }

  private static func RateMaxDOCAction(id: TweakDBID) -> Int32 {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV0") { return 0; }
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV1") { return 1; }
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV2") { return 2; }
    return -1;
  }

  private static func IsBounceBackAction(id: TweakDBID) -> Bool {
    let version = Helper.RateBounceBackAction(id);
    return version != -1;
  }

  private static func RateBounceBackAction(id: TweakDBID) -> Int32 {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "BonesMcCoy70V0") { return 0; }
    if StrBeginsWith(str, "Items") && StrContains(str, "BonesMcCoy70V1") { return 1; }
    if StrBeginsWith(str, "Items") && StrContains(str, "BonesMcCoy70V2") { return 2; }
    return -1;
  }

  private static func IsHealthBoosterAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "HealthBooster") { return true; }
    return false;
  }

  private static func IsBlackLaceAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "BlackLace") { return true; }
    return false;
  }

  private static func IsCapacityBoosterAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "CarryCapacityBooster") { return true; }
    return false;
  }

  private static func IsStaminaBoosterAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "StaminaBooster") { return true; }
    return false;
  }

  private static func IsMemoryBoosterAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "MemoryBooster") { return true; }
    return false;
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

  public static func EffectBaseName(id: TweakDBID) -> TweakDBID {
    let str = TDBID.ToStringDEBUG(id);
    if StrContains(str, "NotablyWeakened") || StrContains(str, "SeverelyWeakened") {
      let base = StrReplace(str, "NotablyWeakened", "");
      base = StrReplace(str, "SeverelyWeakened", "");
      return TDBID.Create(base);
    }
    if StrContains(str, "BlackLace") {
      return TDBID.Create("Items.BlackLaceV0");
    }
    return id;
  }

  public static func AppropriateHintRequest(id: TweakDBID, threshold: Threshold) -> ref<HintRequest> {
    if Helper.IsSerious(threshold) {
      let request: ref<HintRequest>;
      if Helper.IsInhaler(id) {
        request = new CoughingRequest();
      }
      // anabolic are also pills, but the opposite isn't true
      let anabolic = Helper.IsAnabolic(id);
      let pill = Helper.IsPill(id);
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
      if Helper.IsInjector(id) {
        request = new AchingRequest();
      }
      request.threshold = threshold;
      return request;
    }
    return null;
  }

  static public final func MakeGameTime(timestamp: Float) -> GameTime {
    timestamp = Cast<Float>(RoundF(timestamp));
    let days: Float = timestamp / 86400.;
    let hours: Float = (timestamp % 86400.) / 3600.;
    let minutes: Float = ((timestamp % 86400.) % 3600.) / 60.;
    let seconds: Float = (((timestamp % 86400.) % 3600.) % 60.) / 60.;
    let time = GameTime.MakeGameTime(RoundF(days), RoundF(hours), RoundF(minutes), RoundF(seconds));
    return time;
  }
}
