module Addicted

import Addicted.Threshold
import Addicted.System.AddictedSystem
import Addicted.Utils.{E,EI}

// use like:
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.FirstAidWhiffV0"), 40);
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.BonesMcCoy70V0"), 40);
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("BaseStatusEffect.MemoryBooster"), 40);
// where '40' matches Threshold variant
@addMethod(PlayerPuppet)
public func DebugSwitchThreshold(id: TweakDBID, threshold: Int32) -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugSwitchThreshold(id, IntEnum(threshold));
}

// use like: Game.GetPlayer():DebugThresholds();
@addMethod(PlayerPuppet)
public func DebugThresholds() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugThresholds();
}

// use like: Game.GetPlayer():DebugClear();
@addMethod(PlayerPuppet)
public func DebugClear() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugClear();
}

// use like: Game.GetPlayer():DebugClearEffects();
@addMethod(PlayerPuppet)
public func DebugClearEffects() -> Void {
  StatusEffectHelper.RemoveAllStatusEffects(this);
}

@addMethod(PlayerPuppet)
public func DebugWithdrawing() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugWithdrawing();
}

@addMethod(PlayerPuppet)
public func DebugTime() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugTime();
}
