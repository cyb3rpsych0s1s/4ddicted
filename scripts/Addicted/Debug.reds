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

public class SmokeCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let step: Int32;
  public let entityID: EntityID;
  public func Call() -> Void {
    if this.step == 1 {
      GameInstance
      .GetAudioSystem(this.player.GetGame())
      .Play(n"q101_sc_06c_johnny_flicks_cigarette", this.player.GetEntityID(), n"Addicted:Smoke");

      GameObjectEffectHelper
      .StartEffectEvent(this.player, n"cigarette_smoke_exhaust");

      let callback = new SmokeCallback();
      callback.player = this.player;
      callback.step = this.step + 1;
      callback.entityID = this.entityID;
      GameInstance
      .GetDelaySystem(this.player.GetGame())
      .DelayCallback(callback, 3.0);
    }
    if this.step == 2 {
      GameInstance
      .GetWorkspotSystem(this.player.GetGame())
      .SendJumpToAnimEnt(this.player, n"stand_car_lean180__rh_cigarette__01__drop_ash__01", false);

      let callback = new SmokeCallback();
      callback.player = this.player;
      callback.step = this.step + 1;
      callback.entityID = this.entityID;
      GameInstance
      .GetDelaySystem(this.player.GetGame())
      .DelayCallback(callback, 1.6);
    }
    if this.step == 3 {
      GameInstance
      .GetWorkspotSystem(this.player.GetGame())
      .SendJumpToAnimEnt(this.player, n"sit_barstool_bar_lean0__2h_on_bar__01__smoke_ash__01", false);

      let callback = new SmokeCallback();
      callback.player = this.player;
      callback.step = this.step + 1;
      callback.entityID = this.entityID;
      GameInstance
      .GetDelaySystem(this.player.GetGame())
      .DelayCallback(callback, 2.0);
      
    }
    if this.step == 4 {
      GameInstance
      .GetWorkspotSystem(this.player.GetGame())
      .SendJumpToAnimEnt(this.player, n"sit_barstool_bar_lean0__2h_on_bar__01__smoke_idle__01", false);

      let callback = new SmokeCallback();
      callback.player = this.player;
      callback.step = this.step + 1;
      callback.entityID = this.entityID;
      GameInstance
      .GetDelaySystem(this.player.GetGame())
      .DelayCallback(callback, 6.0);
      
    }
    if this.step == 5 {
      GameInstance
      .GetWorkspotSystem(this.player.GetGame())
      .SendJumpToAnimEnt(this.player, n"sit_barstool_bar_lean0__2h_on_bar__01__smoke_ash__01", false);

      GameInstance
      .GetAudioSystem(this.player.GetGame())
      .Play(n"cmn_generic_work_extinguish_cigarette", this.player.GetEntityID(), n"Addicted:Smoke:End");

      let callback = new SmokeCallback();
      callback.player = this.player;
      callback.step = this.step + 1;
      callback.entityID = this.entityID;
      GameInstance
      .GetDelaySystem(this.player.GetGame())
      .DelayCallback(callback, 1.0);
    }
    if this.step == 6 {
      GameObjectEffectHelper
      .BreakEffectLoopEvent(this.player, n"cigarette_smoke_exhaust");

      GameInstance.GetTransactionSystem(this.player.GetGame())
      .RemoveItemFromSlot(this.player, t"AttachmentSlots.WeaponLeft");

      GameInstance
      .GetDynamicEntitySystem()
      .DeleteEntity(this.entityID);

      GameInstance
      .GetWorkspotSystem(this.player.GetGame())
      .SendSlowExitSignal(this.player, n"sit_barstool_bar_lean0__2h_on_bar__01__smoke_ash__01");
    }
  }
}

@addField(PlayerPuppet)
public let entitySystem: ref<DynamicEntitySystem>;

@addMethod(PlayerPuppet)
private cb func OnEntityUpdate(event: ref<DynamicEntityEvent>) {
  LogChannel(n"DEBUG", s"Entity \(event.GetType()) \(EntityID.GetHash(event.GetEntityID())) \(event.GetClassName())");
  if Equals(event.GetTag(), n"Addicted") && Equals(EnumInt(event.GetType()), EnumInt(DynamicEntityEventType.Spawned)) {
    E(s"found event with tag Addicted and entityID \(ToString(event.GetEntityID()))");
    let device = this.entitySystem.GetEntity(event.GetEntityID()) as GameObject;
    // let device = GameInstance.FindEntityByID(this.GetGame(), event.GetEntityID());
    E(s"device: \(device.GetClassName())");
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
    workspotSystem.PlayInDevice(device, this);
    // workspotSystem.SendJumpToTagCommandEnt(this, n"Addicted", true, event.GetEntityID());
    // workspotSystem.SendJumpToTagCommandEnt(this, n"Animated5005", true, event.GetEntityID());
    // workspotSystem.SendJumpToAnimEnt(this, n"Animated5005", true);
    // workspotSystem.SendJumpToAnimEnt(this, n"Addicted", true);
    workspotSystem.SendJumpToAnimEnt(this, n"stand_car_lean180__rh_cigarette__01__smoke__01", true);

    GameInstance.GetTransactionSystem(this.GetGame())
    .GiveItem(this, ItemID.FromTDBID(t"Items.crowd_cigarette_i_stick"), 1);
    GameInstance.GetTransactionSystem(this.GetGame())
    .GiveItem(this, ItemID.FromTDBID(t"Items.apparel_lighter_a"), 1);
    GameInstance.GetTransactionSystem(this.GetGame())
    .AddItemToSlot(this, t"AttachmentSlots.WeaponLeft", ItemID.FromTDBID(t"Items.crowd_cigarette_i_stick"));
    GameInstance.GetTransactionSystem(this.GetGame())
    .AddItemToSlot(this, t"AttachmentSlots.WeaponRight", ItemID.FromTDBID(t"Items.apparel_lighter_a"));
    let left = new AIEquipCommand();
    left.slotId = t"AttachmentSlots.WeaponLeft";
    left.itemId = t"Items.crowd_cigarette_i_stick";
    let right = new AIEquipCommand();
    right.slotId = t"AttachmentSlots.WeaponRight";
    right.itemId = t"Items.apparel_lighter_a";
    let controller = this.GetAIControllerComponent();
    controller.SendCommand(left);
    controller.SendCommand(right);

    let callback = new SmokeCallback();
    callback.player = this;
    callback.step = 1;
    callback.entityID = event.GetEntityID();
    GameInstance
    .GetDelaySystem(this.GetGame())
    .DelayCallback(callback, 3.0);
  }
}

// use like: Game.GetPlayer():Smoke();
@addMethod(PlayerPuppet)
public func Smoke() -> Void {
  this.entitySystem = GameInstance.GetDynamicEntitySystem();
  this.entitySystem.RegisterListener(n"Addicted", this, n"OnEntityUpdate");
  let deviceSpec = new DynamicEntitySpec();
  deviceSpec.templatePath = r"base\\cyberscript\\entity\\smoke.ent";
  deviceSpec.position = this.GetWorldPosition();
  deviceSpec.orientation = EulerAngles.ToQuat(Vector4.ToRotation(this.GetWorldPosition()));
  deviceSpec.persistState = false;
  deviceSpec.persistSpawn = false;
  deviceSpec.tags = [n"Addicted"];
  this.entitySystem.CreateEntity(deviceSpec);
  // let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
  // workspotSystem.SendJumpToTagCommandEnt(this, n"Addicted", true);
  // workspotSystem.SendJumpToAnimEnt(this, n"Animated5005", true);
  // workspotSystem.SendJumpToAnimEnt(this, n"int_recreation_001__cigarette_i_stick", true);
  // workspotSystem.SendJumpToAnimEnt(this, n"base\\items\\interactive\\recreation\\int_recreation_001__cigarette_i_stick.ent", true);
  // workspotSystem.SendJumpToAnimEnt(this, n"crowd_cigarette", true);
  // workspotSystem.SendJumpToAnimEnt(this, n"Items.cigarette_i_stick", true);
  // workspotSystem.SendJumpToAnimEnt(this, n"cigarette_i_stick", true);
}
