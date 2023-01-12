module Addicted
import Addicted.Utils.E

@addMethod(PlayerPuppet)
public func GetAddictionSystem() -> ref<PlayerAddictionSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    return container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
}

@addMethod(PlayerPuppet)
public func Cough() -> Void {
    if !PlayerPuppet.CanApplyOnomatopeaEffect(this) {
        return;
    }
    let system = this.GetAddictionSystem();
    let highest = system.GetHighestThreshold();
    let evt = new SoundPlayEvent();
    evt.soundName = RandomCoughing(this.GetGender(), highest);
    this.QueueEvent(evt);
}

@addMethod(PlayerPuppet)
public func SlowStun() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.SlowStun");
}

@addMethod(PlayerPuppet)
public func IsAddicted(substanceID: TweakDBID) -> Bool {
    let system = this.GetAddictionSystem();
    let threshold = system.GetThreshold(substanceID);
    return EnumInt(threshold) >= EnumInt(Threshold.Mildly);
}

@addMethod(PlayerPuppet)
public func HasAnyAddiction() -> Bool {
    let consumables = AddictiveStatusEffects();
    for consumable in consumables {
        if this.IsAddicted(consumable) { return true; }
    }
    return false;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    E(s"PlayerPuppet:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    let output = wrappedMethod(evt);
    let addictionSystem = this.GetAddictionSystem();
    // increase score on consumption
    if evt.isNewApplication && evt.IsAddictive() {
        addictionSystem.OnAddictiveSubstanceConsumed(evt.staticData.GetID());
    }
    // decrease score on rest
    if evt.staticData.GetID() == t"HousingStatusEffect.Rested" {
        let timeSystem = GameInstance.GetTimeSystem(this.GetGame());
        addictionSystem.OnRested(timeSystem.GetGameTimeStamp());
    }
    return output;
}

@addMethod(PlayerPuppet)
public final static func CanApplyOnomatopeaEffect(player: wref<PlayerPuppet>) -> Bool {
    let blackboard: ref<IBlackboard>;
    if !IsDefined(player) {
      return false;
    };
    if GameplaySettingsSystem.GetAdditiveCameraMovementsSetting(player) <= 0.00 {
      return false;
    };
    if !ScriptedPuppet.IsActive(player) {
      return false;
    };
    blackboard = player.GetPlayerStateMachineBlackboard();
    if !IsDefined(blackboard) {
      return false;
    };
    if blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming) == EnumInt(gamePSMSwimming.Diving) {
      return false;
    };
    let container = GameInstance.GetScriptableSystemsContainer(player.GetGame());
    let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
    return !system.m_no_onomatopea;
}
