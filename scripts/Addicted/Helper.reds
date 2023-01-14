module Addicted

import Addicted.*
import Addicted.Utils.E

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
    switch(id) {
      case t"BaseStatusEffect.FirstAidWhiffV0":
      case t"BaseStatusEffect.FirstAidWhiffV1":
      case t"BaseStatusEffect.FirstAidWhiffV2":
      case t"BaseStatusEffect.BounceBackV0":
      case t"BaseStatusEffect.BounceBackV1":
      case t"BaseStatusEffect.BounceBackV2":
      case t"BaseStatusEffect.HealthBooster":
        return true;
      default:
        break;
    }
    return false;
  }

  public static func IsHealerAction(id: TweakDBID) -> Bool {
    switch(id) {
      case t"Items.FirstAidWhiffV0_inline2":
        return true;
      default:
        break;
    }
    return false;
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
    switch(id) {
      case t"BaseStatusEffect.FirstAidWhiffV0":
      case t"BaseStatusEffect.FirstAidWhiffV1":
      case t"BaseStatusEffect.FirstAidWhiffV2":
        return true;
      default:
        break;
    }
    return false;
  }

  public static func IsInjector(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.BlackLaceV0":
      case t"BaseStatusEffect.BounceBackV0":
      case t"BaseStatusEffect.BounceBackV1":
      case t"BaseStatusEffect.BounceBackV2":
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

  public static func Consumable(id: TweakDBID) -> Consumable {
    switch(id) {
      case t"BaseStatusEffect.AlcoholDebuff":
        return Consumable.Alcohol;
      case t"BaseStatusEffect.FirstAidWhiffV0":
      case t"BaseStatusEffect.FirstAidWhiffV1":
      case t"BaseStatusEffect.FirstAidWhiffV2":
        return Consumable.BounceBack;
      case t"BaseStatusEffect.BounceBackV0":
      case t"BaseStatusEffect.BounceBackV1":
      case t"BaseStatusEffect.BounceBackV2":
        return Consumable.MaxDOC;
      case t"BaseStatusEffect.HealthBooster":
        return Consumable.HealthBooster;
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
          t"BaseStatusEffect.FirstAidWhiffV0",
          t"BaseStatusEffect.FirstAidWhiffV1",
          t"BaseStatusEffect.FirstAidWhiffV2"
        ];
      case Consumable.MaxDOC:
        return [
          t"BaseStatusEffect.BounceBackV0",
          t"BaseStatusEffect.BounceBackV1",
          t"BaseStatusEffect.BounceBackV2"
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
    switch(id) {
      case t"Items.FirstAidWhiffV0_inline2":
        if serious {
          return t"Items.FirstAidWhiffV0_inline2_greatly_weakened";
        }
        return t"Items.FirstAidWhiffV0_inline2_weakened";
      default:
        break;
    }
    return TDBID.None();
  }

  public static func IsAddictive(id: TweakDBID) -> Bool {
    switch(id) {
      case t"":
      case t"BaseStatusEffect.AlcoholDebuff":
      // t"BaseStatusEffect.CombatStim" double-check
      case t"BaseStatusEffect.FirstAidWhiffV0":
      case t"BaseStatusEffect.FirstAidWhiffV1":
      case t"BaseStatusEffect.FirstAidWhiffV2":
      case t"BaseStatusEffect.BonesMcCoy70V0":
      case t"BaseStatusEffect.BonesMcCoy70V1":
      case t"BaseStatusEffect.BonesMcCoy70V2":
      case t"BaseStatusEffect.BlackLaceV0":
      case t"BaseStatusEffect.HealthBooster":
      case t"BaseStatusEffect.CarryCapacityBooster":
      case t"BaseStatusEffect.StaminaBooster":
      case t"BaseStatusEffect.MemoryBooster":
      case t"BaseStatusEffect.OxyBooster":
        return true;
      default:
        break;
    }
    return false;
  }

  public static func IsSerious(threshold: Threshold) -> Bool {
    return EnumInt(threshold) == EnumInt(Threshold.Notably) || EnumInt(threshold) == EnumInt(Threshold.Notably);
  }
}
