module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.Generic

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
    let id: TweakDBID;
    let groupThreshold = this.system.Threshold(Addiction.Healers);
    for effect in actionEffects {
      id = effect.GetID();
      consumable = Generic.Consumable(id);
      threshold = this.system.Threshold(consumable);
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
      if Generic.IsHealer(record.GetID()) {
        return true;
      }
    }
    return false;
  }
}