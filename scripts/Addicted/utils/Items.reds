module Addicted.Helpers

// items helper
public class Items {

  public static func IsDetoxifier(id: TweakDBID) -> Bool { return Equals(id, t"Items.ToxinCleanser"); }
  public static func IsMetabolicEditor(id: TweakDBID) -> Bool { return Equals(id, t"Items.ReverseMetabolicEnhancer"); }

  private static func IsMaxDOCAction(id: TweakDBID) -> Bool {
    let rate = Items.RateMaxDOCAction(id);
    return rate != -1;
  }

  private static func IsBounceBackAction(id: TweakDBID) -> Bool {
    let version = Items.RateBounceBackAction(id);
    return version != -1;
  }

  public static func IsHealerAction(id: TweakDBID) -> Bool {
    return Generic.IsMaxDOC(id) || Generic.IsBounceBack(id) || Generic.IsHealthBooster(id);
  }

  public static func IsBoosterAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    return StrBeginsWith(str, "Items") && StrContains(str, "Booster");
  }

  public static func IsInhalerAction(id: TweakDBID) -> Bool {
    return Items.IsMaxDOCAction(id) || Items.IsBlackLaceAction(id);
  }

  public static func IsInjectorAction(id: TweakDBID) -> Bool {
    return Items.IsBounceBackAction(id);
  }

  public static func IsPillAction(id: TweakDBID) -> Bool {
    return Generic.IsCapacityBooster(id) ||
    Items.IsStaminaBoosterAction(id) ||
    Items.IsMemoryBoosterAction(id);
  }

  public static func IsAnabolicAction(id: TweakDBID) -> Bool {
    return Items.IsCapacityBoosterAction(id) || Items.IsStaminaBoosterAction(id);
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

  private static func RateMaxDOCAction(id: TweakDBID) -> Int32 {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV0") { return 0; }
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV1") { return 1; }
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV2") { return 2; }
    return -1;
  }
}