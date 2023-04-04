module Addicted

import Addicted.Threshold
import Addicted.System.AddictedSystem
import Addicted.Utils.{E,EI}
import Addicted.Helpers.Generic
import Codeware.Localization.*

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

@wrapMethod(SingleCooldownManager)
public final func ActivateCooldown(buffData: UIBuffInfo) -> Void {
  wrappedMethod(buffData);
  let effectUIData: wref<StatusEffectUIData_Record>;
  let i: Int32;
  let effect: wref<StatusEffect_Record> = TweakDBInterface.GetStatusEffectRecord(this.m_buffData.buffID);
  if IsDefined(effect) {
    effectUIData = effect.UiData();
    if IsDefined(effectUIData) {
      if effectUIData.GetNameValuesCount() > 0 {
          i = 0;
          while i < effectUIData.GetNameValuesCount() {
            E(s"name_\(i) => \(effectUIData.GetNameValuesItem(i)) = \(GetLocalizedText(NameToString(effectUIData.GetNameValuesItem(i))))");
            i += 1;
          };
      }
    }
  }
}

// use like:
// Game.GetPlayer():DebugEffect("NotablyWithdrawnFromMemoryBooster")
@addMethod(PlayerPuppet)
public func DebugEffect(name: String) -> Void {
  let c_name = "BaseStatusEffect." + name;
  let id = TDBID.Create(c_name);
  let callback: ref<TestVFXThresholdCallback> = new TestVFXThresholdCallback();
  callback.id = id;
  callback.player = this;

  GameInstance
    .GetDelaySystem(this.GetGame())
    .DelayCallback(callback, 0.1);
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

// use like: Game.GetPlayer():DebugSetWithdrawing("BlackLaceV0", true);
@addMethod(PlayerPuppet)
public func DebugSetWithdrawing(consumable: String, value: Bool) -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  let c_name = "BaseStatusEffect." + consumable;
  let id = TDBID.Create(c_name);
  let c = Generic.Consumable(id);
  system.DebugSetWithdrawing(c, value);
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
  let chemicals = system.Chemicals();
  event.Symptoms = symptoms;
  event.Chemicals = chemicals;
  event.Customer = customer;
  event.boot = true;
  event.Dismissable = true;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(event);
}

// use like: Game.GetPlayer():Checkup();
@addMethod(PlayerPuppet)
public func Checkup() -> Void {
  let system = AddictedSystem.GetInstance(this.GetGame());
  system.Checkup();
}

// use like: Game.GetPlayer():DebugSound("v_scene_rogue_default_m_1af69f1db32d2000"); // vanilla
// use like: Game.GetPlayer():DebugSound("addicted.en-us.fem_v_as_if_I_didnt_know_already"); // custom sounds
@addMethod(PlayerPuppet)
public func DebugSound(sound: String) -> Void {
  GameObject.PlaySound(this, StringToName(sound));
}

// use like: Game.GetPlayer():DebugVoiceOver("addicted.en-us.fem_v_as_if_I_didnt_know_already"); // custom sounds
@addMethod(PlayerPuppet)
public func DebugVoiceOver(sound: String) -> Void {
  GameObject.PlayVoiceOver(this, StringToName(sound), n"Scripts:AddictedDebugVoiceOver");
}

// use like: Game.GetPlayer():DebugSubtitle("Addicted-Voice-Subtitle-as_if_I_didnt_know_already");
// @addMethod(PlayerPuppet)
// public func DebugSubtitle(key: String) -> Void {
//   let localization = LocalizationSystem.GetInstance(this.GetGame()) as LocalizationSystem;
//   let text = localization.GetSubtitle(key);
//   // let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UIGameData);
//   let line = this.CreateSubtitle(text);
//   // board.SetVariant(GetAllBlackboardDefs().UIGameData.ShowDialogLine, ToVariant([line]), true);
//   E(s"subtitle: \(line.text)");
// }
