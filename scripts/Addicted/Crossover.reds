module Addicted.Crossover

@if(ModuleExists("Edgerunning.System"))
import Edgerunning.System.EdgerunningSystem

import Addicted.Threshold
import Addicted.Helper
import Addicted.Consumable
import Addicted.Utils.E

@if(!ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
protected func HandleHumanityPenalty(count: Int32, threshold: Threshold) -> Void {}

@if(ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
protected func HandleHumanityPenalty(count: Int32, threshold: Threshold) -> Void {
  let edgerunning: ref<EdgerunningSystem> = EdgerunningSystem.GetInstance(this.GetGame()) as EdgerunningSystem;
  let current: Int32 = edgerunning.GetPenaltyByKey("Mod-Addicted-Edgerunning-BlackLace-Penalty");
  let exists: Bool = NotEquals(current, -1);
  let serious: Bool = Helper.IsSerious(threshold);
  E(s"handle humanity penalty (wannabe edgerunner)\ncount: \(count), current: \(current), exists: \(exists), threshold: \(ToString(threshold)), serious: \(serious)");

  if serious {
    let multiplier: Int32 = Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) ? 6 : 3;
    let value: Int32 = Min(5, count);
    let penalty: Int32 = value * multiplier;
    E(s"current penalty \(current), updated penalty \(penalty)");
    if NotEquals(current, penalty) {
      edgerunning.AddHumanityPenalty("Mod-Addicted-Edgerunning-BlackLace-Penalty", penalty);
    }
    return;
  }
  if !serious && exists {
    edgerunning.RemoveHumanityPenalty("Mod-Addicted-Edgerunning-BlackLace-Penalty");
    return;
  }
}
    