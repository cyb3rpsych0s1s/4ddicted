module Addicted

import Addicted.Threshold
import Addicted.System.AddictedSystem
import Addicted.Utils.{E,EI}

public class TestVFXThresholdCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let id: TweakDBID;
  public func Call() -> Void {
    this.player.DebugClearEffects();
    EI(this.id, s"playing VFX");
    GameInstance
    .GetStatusEffectSystem(this.player.GetGame())
    .ApplyStatusEffect(this.player.GetEntityID(), this.id, this.player.GetRecordID(), this.player.GetEntityID());
  }
}

// use like:
// Game.GetPlayer():TestVFX("FirstAidWhiffV0")
// Game.GetPlayer():TestVFX("BonesMcCoy70V0")
// Game.GetPlayer():TestVFX("HealthBooster")
@addMethod(PlayerPuppet)
public func TestVFX(version: String) -> Void {
  let c_name = "BaseStatusEffect." + version;
  let clean: ref<TestVFXThresholdCallback> = new TestVFXThresholdCallback();
  clean.id = TDBID.Create(c_name);
  clean.player = this;

  let n_name = "BaseStatusEffect.NotablyWeakened" + version;
  let notable: ref<TestVFXThresholdCallback> = new TestVFXThresholdCallback();
  notable.id = TDBID.Create(n_name);
  notable.player = this;

  let s_name = "BaseStatusEffect.SeverelyWeakened" + version;
  let severe: ref<TestVFXThresholdCallback> = new TestVFXThresholdCallback();
  severe.id =  TDBID.Create(s_name);
  severe.player = this;

  GameInstance
    .GetDelaySystem(this.GetGame())
    .DelayCallback(clean, 4);

  GameInstance
    .GetDelaySystem(this.GetGame())
    .DelayCallback(notable, 8);

  GameInstance
    .GetDelaySystem(this.GetGame())
    .DelayCallback(severe, 12);
}

// use like:
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("Items.FirstAidWhiffV0"), 40);
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("Items.BonesMcCoy70V0"), 40);
// Game.GetPlayer():DebugSwitchThreshold(TweakDBID.new("Items.MemoryBooster"), 40);
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

// use like: Game.GetPlayer():DebugWithdrawing();
@addMethod(PlayerPuppet)
public func DebugWithdrawing() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugWithdrawing();
}

// use like: Game.GetPlayer():DebugTime();
@addMethod(PlayerPuppet)
public func DebugTime() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.DebugTime();
}

// use like: Game.GetPlayer():DebugBiomon();
@addMethod(PlayerPuppet)
public func DebugBiomon() -> Void {
  let event: ref<CrossThresholdEvent> = new CrossThresholdEvent();
  let customer: ref<Customer> = new Customer();
  customer.FirstName = "V";
  customer.LastName = "UNKNOWN";
  customer.Age = "27";
  customer.BloodGroup = "UNKNOWN";
  customer.Insurance = "-";
  let system: ref<AddictedSystem> = AddictedSystem.GetInstance(this.GetGame());
  let symptoms = system.Symptoms();
  event.Symptoms = symptoms;
  event.Customer = customer;
  event.boot = true;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(event);
}

// use like: Game.GetPlayer():Checkup();
@addMethod(PlayerPuppet)
public func Checkup() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.Checkup();
}
