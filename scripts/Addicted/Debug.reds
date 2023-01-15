import Addicted.Threshold
import Addicted.System.AddictedSystem

// use like: Game.GetPlayer():DebugThreshold(TweakDBID.new("BaseStatusEffect.FirstAidWhiffV0"), 40);
@addMethod(PlayerPuppet)
public func DebugThreshold(id: TweakDBID, threshold: Int32) -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame()) as AddictedSystem;
  system.DebugSetThreshold(id, IntEnum(threshold));
}