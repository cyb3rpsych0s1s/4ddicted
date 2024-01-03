module Addicted.Helpers

// status effect based helper
public class Effect {

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

  public static func IsSleep(id: TweakDBID) -> Bool { return Equals(id, t"HousingStatusEffect.Rested"); }

  public static func IsInstant(record: ref<TweakDBRecord>) -> Bool {
    if record.IsA(n"gamedataStatusEffect_Record") {
      let status = record as StatusEffect_Record;
      let id = status.GetID();
      let str = TDBID.ToStringDEBUG(id);
      let suffix = StrAfterFirst(str, ".");
      return StrContains(suffix, "FirstAidWhiff");
    }
    return false;
  }

  public static func IsApplied(effects: array<ref<StatusEffect>>, id: TweakDBID) -> Bool {
    for effect in effects {
      if Equals(effect.GetRecord().GetID(), id) {
        return true;
      }
    }
    return false;
  }

  public static func AreApplied(effects: array<ref<StatusEffect>>, ids: array<TweakDBID>) -> Bool {
    let contains: Bool;
    for effect in effects {
      contains = ArrayContains(ids, effect.GetRecord().GetID());
      if contains {
        return true;
      }
    }
    return false;
  }
}