module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.*
import Addicted.Utils.*

public class HealerManager extends IScriptable {

  private let system: wref<AddictedSystem>;

  public final func Initialize(system: ref<AddictedSystem>) -> Void {
    this.system = system;
  }

  /// weaken healers efficiency by subtituting them with debuffed ones
  /// this is because actionEffects are immutable
  protected func AlterHealerStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
    let idx = 0;
    let action: TweakDBID;
    let threshold: Threshold;
    let consumable: Consumable;
    let average: Int32;
    let id: TweakDBID;
    let groupAverage = this.system.AverageAddiction(Addiction.Healers);
    let groupThreshold = Helper.Threshold(groupAverage);
    for effect in actionEffects {
      id = effect.GetID();
      consumable = Helper.Consumable(id);
      average = this.system.AverageConsumption(consumable);
      threshold = Helper.Threshold(average);
      if EnumInt(threshold) < EnumInt(groupThreshold) {
        threshold = groupThreshold;
      }
      action = Helper.ActionEffect(id, threshold);
      if !Equals(action, id) {
        EI(id, s"replace with \(TDBID.ToStringDEBUG(action))");
        let weakened = TweakDBInterface.GetObjectActionEffectRecord(action);
        actionEffects[idx] = weakened;
      }
      idx += 1;
    }
    return actionEffects;
  }

  public func ContainsHealerStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> Bool {
    for record in actionEffects {
      if Helper.IsHealer(record.GetID()) {
        return true;
      }
    }
    return false;
  }
}