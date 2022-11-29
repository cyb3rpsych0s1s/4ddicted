module Addicted

@wrapMethod(RestedEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let system = GameInstance.GetTimeSystem(scriptInterface.GetGame());
    LogChannel(n"DEBUG", "OnEnter " + ToString(system.GetGameTimeStamp()));
    wrappedMethod(stateContext, scriptInterface);
}

@addMethod(PlayerPuppet)
public func GetAddictionSystem() -> ref<PlayerAddictionSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    return container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
}

@addMethod(PlayerPuppet)
public func IsAddicted(substanceID: TweakDBID) -> Bool {
    let system = this.GetAddictionSystem();
    let threshold = system.GetThreshold(substanceID);
    return threshold != -1;
}

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    return ArrayContains(
        [
            t"BaseStatusEffect.AlcoholDebuff",
            // t"BaseStatusEffect.CombatStim", // double-check
            t"BaseStatusEffect.FirstAidWhiffV0",
            t"BaseStatusEffect.FirstAidWhiffV1",
            t"BaseStatusEffect.FirstAidWhiffV2",
            t"BaseStatusEffect.BonesMcCoy70V0",
            t"BaseStatusEffect.BonesMcCoy70V1",
            t"BaseStatusEffect.BonesMcCoy70V2",
            t"BaseStatusEffect.BlackLaceV0",
            t"BaseStatusEffect.HealthBooster",
            t"BaseStatusEffect.CarryCapacityBooster",
            t"BaseStatusEffect.StaminaBooster",
            t"BaseStatusEffect.MemoryBooster",
            t"BaseStatusEffect.OxyBooster",
            // TODO: add missing (mod based)
            t"BaseStatusEffect.FR3SH",
            t"BaseStatusEffect.Glitter",
            t"BaseStatusEffect.SecondWind",
            t"BaseStatusEffect.Evade",
            t"BaseStatusEffect.BeRiteBack",
            t"BaseStatusEffect.Locus",
            t"BaseStatusEffect.RainbowPoppers"
        ],
        this.staticData.GetID());
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID())) \(ToString(evt.staticData.StatusEffectType().Type()))");
    let output = wrappedMethod(evt);
    let addictionSystem = this.GetAddictionSystem();
    if evt.isNewApplication && evt.IsAddictive() {
        addictionSystem.OnAddictiveSubstanceConsumed(evt.staticData.GetID());
    }
    if evt.staticData.GetID() == t"HousingStatusEffect.Rested" {
        let timeSystem = GameInstance.GetTimeSystem(this.GetGame());
        addictionSystem.OnRested(timeSystem.GetGameTimeStamp());
    }
    return output;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    if evt.IsAddictive() {
        LogChannel(n"DEBUG","RED:Addicted:OnStatusEffectRemoved (IsAddictive)");
    }
  return wrappedMethod(evt);
}