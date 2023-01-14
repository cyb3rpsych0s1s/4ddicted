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

  static public final func Consumable(id: TweakDBID) -> Consumable {
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

  static public final func Consumables(addiction: Addiction) -> array<Consumable> {
    switch(addiction) {
      case Addiction.Healers:
        return [Consumable.BounceBack, Consumable.MaxDOC, Consumable.HealthBooster];
    }
  }

  static public final func Effects(consumable: Consumable) -> array<TweakDBID> {
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
}
