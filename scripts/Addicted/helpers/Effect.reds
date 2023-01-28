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

  public static func IsInstant(record: ref<TweakDBRecord>) -> Bool {
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