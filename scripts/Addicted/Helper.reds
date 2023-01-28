module Addicted

import Addicted.*
import Addicted.Utils.{E,EI}

public class Bits {
  public static func ShiftRight(num: Int32, n: Int32) -> Int32 {
    num / PowI(2, n)
  }

  public static func ShiftLeft(num: Int32, n: Int32) -> Int32 {
    num * PowI(2, n)
  }

  public static func PowI(num: Int32, times: Int32) -> Int32 {
    RoundMath(Cast<Float>(num).PowF(times))
  }

  public static func Invert(num: Int32) -> Int32 {
    let i = 0;
    while i < 32 {
      num = PowI(num, ShiftLeft(1, i));
      i += 1;
    }
    return num;
  }

  public static func Has(num: Int32, n: Int32) -> Bool {
    return Bits.ShiftRight(num, n) & 1;
  }
  
  public static func Set(num: Int32, n: Int32, value: Bool) -> Int32 {
    let after = num;
    if value {
      // set bit to 1
      after |= Bits.ShiftLeft(1, n);
    } else {
      // set bit to 0
      after &= Bits.Invert(Bits.ShiftLeft(1, n));
    }
    return after;
  }
}

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
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "Booster");
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

  public static func IsNeurotransmitter(id: TweakDBID) -> Bool {
    return Helper.IsMemoryBooster(id);
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
    let record = TweakDBInterface.GetRecord(id);
    let effect = Helper.IsInstantEffect(record);
    if effect { return true; }
    let item = Helper.IsInstantItem(record);
    if item { return true; }
    return false;
  }

  public static func IsInstantEffect(record: ref<TweakDBRecord>) -> Bool {
    if record.IsA(n"gamedataStatusEffect_Record") {
      let status = record as StatusEffect_Record;
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

  public static func IsInstantItem(record: ref<TweakDBRecord>) -> Bool {
    if record.IsA(n"gamedataConsumableItem_Record") {
      let item = record as Item_Record;
      let size = item.GetObjectActionsCount();
      if size == 0 { return false ;}
      let actions: array<wref<ObjectAction_Record>> = [];
      let effectors: array<wref<ObjectActionEffect_Record>> = [];
      let status: wref<StatusEffect_Record>;
      let found: Bool = false;
      item.ObjectActions(actions);
      for action in actions {
        if Equals(action.ActionName(), n"Consume") {
          effectors = [];
          action.CompletionEffects(effectors);
          for effector in effectors {
            status = effector.StatusEffect();
            found = Helper.IsInstantEffect(status);
            if found {
              return true;
            }
          }
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
      case Addiction.Anabolics:
        return [Consumable.StaminaBooster, Consumable.CarryCapacityBooster];
      case Addiction.Neuros:
        return [Consumable.MemoryBooster];
      default:
        break;
    }
    return [];
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
          t"Items.HealthBooster",
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

  public static func IsBiomonitor(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrBeginsWith(suffix, "HealthMonitor");
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

  public static func IsDetoxifier(id: TweakDBID) -> Bool { return Equals(id, t"Items.ToxinCleanser"); }
  public static func IsMetabolicEditor(id: TweakDBID) -> Bool { return Equals(id, t"Items.ReverseMetabolicEnhancer"); }

  public static func IsSleep(id: TweakDBID) -> Bool { return Equals(id, t"HousingStatusEffect.Rested"); }

  public static func IsAlcohol(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    return StrContains(str, "Alcohol");
  }

  public static func IsMaxDOC(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "FirstAidWhiff");
  }

  public static func IsBounceBack(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "BonesMcCoy70");
  }

  public static func IsHealthBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "HealthBooster");
  }

  public static func IsBlackLace(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "BlackLace");
  }

  public static func IsCapacityBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "CarryCapacityBooster");
  }

  public static func IsStaminaBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "StaminaBooster");
  }

  public static func IsMemoryBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "MemoryBooster");
  }

  public static func IsOxyBooster(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    return StrContains(suffix, "OxyBooster");
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

  // get a general item name based on any TweakDBID related to a consumable
  // e.g. 'BaseStatusEffect.NotablyWeakenedFirstAidWhiffV0' or 'Items.FirstAidWhiffV0', etc
  //       would become 'Items.FirstAidWhiffV0'  
  public static func ItemBaseName(id: TweakDBID) -> TweakDBID {
    let str = TDBID.ToStringDEBUG(id);
    let suffix = StrAfterFirst(str, ".");
    if StrContains(suffix, "NotablyWeakened") || StrContains(suffix, "SeverelyWeakened") {
      suffix = StrReplace(suffix, "NotablyWeakened", "");
      suffix = StrReplace(suffix, "SeverelyWeakened", "");
      return TDBID.Create("Items." + suffix);
    }
    if StrContains(str, "BlackLace") {
      return TDBID.Create("Items.BlackLaceV0");
    }
    return TDBID.Create("Items." + suffix);
  }

  public static func AppropriateHintRequest(id: TweakDBID, threshold: Threshold, now: Float) -> ref<HintRequest> {
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
