module Addicted.Helpers

import Addicted.*
import Addicted.Utils.{E,EI,F}

// items helper
public class Items {

  public static func IsDetoxifier(id: TweakDBID) -> Bool { return Equals(id, t"Items.ToxinCleanser"); }
  public static func IsMetabolicEditor(id: TweakDBID) -> Bool { return Equals(id, t"Items.ReverseMetabolicEnhancer"); }

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

  private static func IsNeuroBlockerAction(id: TweakDBID) -> Bool {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrEndsWith(str, "ripperdoc_med") { return true; }
    if StrBeginsWith(str, "Items") && StrEndsWith(str, "ripperdoc_med_uncommon") { return true; }
    if StrBeginsWith(str, "Items") && StrEndsWith(str, "ripperdoc_med_common") { return true; }
    return false;
  }

  private static func RateMaxDOCAction(id: TweakDBID) -> Int32 {
    let str = TDBID.ToStringDEBUG(id);
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV0") { return 0; }
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV1") { return 1; }
    if StrBeginsWith(str, "Items") && StrContains(str, "FirstAidWhiffV2") { return 2; }
    return -1;
  }

  public static func ActionEffect(id: TweakDBID, threshold: Threshold) -> TweakDBID {
    E(s"action effect for \(TDBID.ToStringDEBUG(id))");
    let serious = Helper.IsSerious(threshold);
    if !serious {
      return id;
    }
    let severe = EnumInt(threshold) == EnumInt(Threshold.Severely);
    if Generic.IsMaxDOC(id) {
      let version = Items.RateMaxDOCAction(id);
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
    if Generic.IsBounceBack(id) {
      let version = Items.RateBounceBackAction(id);
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
    if Generic.IsHealthBooster(id) {
      if severe {
        return t"Items.SeverelyWeakenedActionEffectHealthBooster";
      }
      return t"Items.NotablyWeakenedActionEffectHealthBooster";
    }
    return id;
  }

  public static func IsInstant(record: ref<TweakDBRecord>) -> Bool {
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
            found = Effect.IsInstant(status);
            if found {
              return true;
            }
          }
        }
      }
    }
    return false;
  }
}