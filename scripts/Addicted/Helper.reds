module Addicted

import Addicted.*
import Addicted.Utils.{E,EI}

public class Helper {
  public static func Category(id: TweakDBID) -> Category {
    switch(id) {
      case t"BaseStatusEffect.BlackLaceV0":
        return Category.Hard;
      default:
        break;
    }
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
    switch(id) {
      case t"BaseStatusEffect.StaminaBooster":
      case t"BaseStatusEffect.CarryCapacityBooster":
        return true;
      default:
        break;
    }
    return false;
  }

  public static func IsInhaler(id: TweakDBID) -> Bool {
    return Helper.IsMaxDOC(id);
  }

  public static func IsInjector(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.BlackLaceV0":
      case t"BaseStatusEffect.BonesMcCoy70V0":
      case t"BaseStatusEffect.BonesMcCoy70V1":
      case t"BaseStatusEffect.BonesMcCoy70V2":
        return true;
      default:
        break;
    }
    return false;
  }

  public static func IsPill(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.StaminaBooster":
      case t"BaseStatusEffect.CarryCapacityBooster":
        return true;
      default:
        break;
    }
    return false;
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
        if Equals(stat.GetID(), t"BaseStats.MaxDuration") && Equals(rtype, n"Additive") && record.IsA(n"ConstantStatModifier_Record") {
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
      case Consumable.BounceBack:
        return [
          t"BaseStatusEffect.BonesMcCoy70V0",
          t"BaseStatusEffect.BonesMcCoy70V1",
          t"BaseStatusEffect.BonesMcCoy70V2"
        ];
      case Consumable.MaxDOC:
        return [
          t"BaseStatusEffect.FirstAidWhiffV0",
          t"BaseStatusEffect.FirstAidWhiffV1",
          t"BaseStatusEffect.FirstAidWhiffV2"
        ];
      case Consumable.HealthBooster:
        return [t"BaseStatusEffect.HealthBooster"];
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
    switch(id) {
      case t"Items.FirstAidWhiffV0_inline2":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectFirstAidWhiffV0";
        }
        return t"Items.NotablyWeakenedActionEffectFirstAidWhiffV0";
      case t"Items.FirstAidWhiffV1_inline6":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectFirstAidWhiffV1";
        }
        return t"Items.NotablyWeakenedActionEffectFirstAidWhiffV1";
      case t"Items.FirstAidWhiffV2_inline6":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectFirstAidWhiffV2";
        }
        return t"Items.NotablyWeakenedActionEffectFirstAidWhiffV2";
      case t"Items.BonesMcCoy70V0_inline0":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V0";
        }
        return t"Items.NotablyWeakenedActionEffectBonesMcCoy70V0";
      case t"Items.BonesMcCoy70V1_inline0":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V1";
        }
        return t"Items.NotablyWeakenedActionEffectBonesMcCoy70V1";
      case t"Items.BonesMcCoy70V2_inline6":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V2";
        }
        return t"Items.NotablyWeakenedActionEffectBonesMcCoy70V2";
      case t"Items.HealthBooster_inline1":
        if severe {
          return t"Items.SeverelyWeakenedActionEffectHealthBooster";
        }
        return t"Items.NotablyWeakenedActionEffectHealthBooster";
      default:
        break;
    }
    return id;
  }

  public static func IsAddictive(id: TweakDBID) -> Bool {
    switch(id) {
      case t"":
      case t"BaseStatusEffect.AlcoholDebuff":
      // t"BaseStatusEffect.CombatStim" double-check
      case t"BaseStatusEffect.BlackLaceV0":
      case t"BaseStatusEffect.CarryCapacityBooster":
      case t"BaseStatusEffect.StaminaBooster":
      case t"BaseStatusEffect.MemoryBooster":
      case t"BaseStatusEffect.OxyBooster":
        return true;
      default:
        break;
    }
    return Helper.IsMaxDOC(id) || Helper.IsBounceBack(id) || Helper.IsHealthBooster(id);
  }

  public static func IsSerious(threshold: Threshold) -> Bool {
    return EnumInt(threshold) == EnumInt(Threshold.Notably) || EnumInt(threshold) == EnumInt(Threshold.Notably);
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

  public static func IsMaxDOC(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.FirstAidWhiffV0":
      case t"BaseStatusEffect.FirstAidWhiffV1":
      case t"BaseStatusEffect.FirstAidWhiffV2":
      case t"BaseStatusEffect.NotablyWeakenedFirstAidWhiffV0":
      case t"BaseStatusEffect.NotablyWeakenedFirstAidWhiffV1":
      case t"BaseStatusEffect.NotablyWeakenedFirstAidWhiffV2":
      case t"BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV0":
      case t"BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV1":
      case t"BaseStatusEffect.SeverelyWeakenedFirstAidWhiffV2":
        return true;
      default:
        break;
    }
    return Helper.IsMaxDOCAction(id);
  }

  public static func IsBounceBack(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.BonesMcCoy70V0":
      case t"BaseStatusEffect.BonesMcCoy70V1":
      case t"BaseStatusEffect.BonesMcCoy70V2":
      case t"BaseStatusEffect.NotablyWeakenedBonesMcCoy70V0":
      case t"BaseStatusEffect.NotablyWeakenedBonesMcCoy70V1":
      case t"BaseStatusEffect.NotablyWeakenedBonesMcCoy70V2":
      case t"BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V0":
      case t"BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V1":
      case t"BaseStatusEffect.SeverelyWeakenedBonesMcCoy70V2":
        return true;
      default:
        break;
    }
    return Helper.IsBounceBackAction(id);
  }

  public static func IsHealthBooster(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.HealthBooster":
      case t"BaseStatusEffect.NotablyWeakenedHealthBooster":
      case t"BaseStatusEffect.SeverelyWeakenedHealthBooster":
        return true;
      default:
        break;
    }
    return false;
  }

  private static func IsMaxDOCAction(id: TweakDBID) -> Bool {
    switch(id) {
      case t"Items.FirstAidWhiffV0_inline2":
      case t"Items.FirstAidWhiffV1_inline6":
      case t"Items.FirstAidWhiffV2_inline6":
        return true;
      default:
        break;
    }
    return false;
  }

  private static func IsBounceBackAction(id: TweakDBID) -> Bool {
    switch(id) {
      case t"Items.BonesMcCoy70V0_inline2":
      case t"Items.BonesMcCoy70V1_inline2":
      case t"Items.BonesMcCoy70V2_inline6":
        return true;
      default:
        break;
    }
    return false;
  }
}
