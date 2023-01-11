module Addicted

@addMethod(PlayerPuppet)
public func GetAddictionSystem() -> ref<PlayerAddictionSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    return container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
}

@addMethod(PlayerPuppet)
public func Cough() -> Void {
    let system = this.GetAddictionSystem();
    let highest = system.GetHighestThreshold();
    let evt = new SoundPlayEvent();
    evt.soundName = RandomCoughing(this.GetGender(), highest);
    this.QueueEvent(evt);
}

@addMethod(PlayerPuppet)
public func FeelsDizzy() -> Void {
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 3.00);
    StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.MaxDOCMirage");
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
    LogChannel(n"DEBUG", s"RED:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
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
