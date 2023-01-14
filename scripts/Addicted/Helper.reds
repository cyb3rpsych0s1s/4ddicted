module Addicted

public final class Helper {
  static public final func Category(id: TweakDBID) -> Category {
    switch(id) {
      case t"BaseStatusEffect.BlackLaceV0":
        return Category.Hard;
      default:
        return Category.Mild;
    }
  }

  static public final func Potency(id: TweakDBID) -> Int32 {
    switch(Helper.Category(id)) {
      case Category.Hard:
        return 1;
      case Category.Mild:
        return 2;
    }
  }

  static public final func Resilience(id: TweakDBID) -> Int32 {
    switch(Helper.Category(id)) {
      case Category.Hard:
        return 2;
      case Category.Mild:
        return 1;
    }
  }

  static public final func Threshold(score: Int32) -> Threshold {
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

  static public final func IsHealer(id: TweakDBID) -> Bool {
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

  static public final func IsBooster(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.StaminaBooster":
      case t"BaseStatusEffect.CarryCapacityBooster":
        return true;
      default:
        break;
    }
    return false;
  }

  static public final func IsInhaler(id: TweakDBID) -> Bool {
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

  static public final func IsInjector(id: TweakDBID) -> Bool {
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

  static public final func IsPill(id: TweakDBID) -> Bool {
    switch(id) {
      case t"BaseStatusEffect.StaminaBooster":
      case t"BaseStatusEffect.CarryCapacityBooster":
        return true;
      default:
        break;
    }
    return false;
  }
}
