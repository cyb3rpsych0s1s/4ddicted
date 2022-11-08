module Addicted

@wrapMethod(RestedEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let system = GameInstance.GetTimeSystem(scriptInterface.GetGame());
    LogChannel(n"DEBUG", "OnEnter " + ToString(system.GetGameTimeStamp()));
    wrappedMethod(stateContext, scriptInterface);
}

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    return ArrayContains(
        [
            t"BaseStatusEffect.FirstAidWhiffV0",
            t"BaseStatusEffect.BonesMcCoy70V0"
            // TODO: add missing
        ],
        this.staticData.GetID());
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    let output = wrappedMethod(evt);
    if evt.isNewApplication && evt.IsAddictive() {
        let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
        let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
        system.OnAddictiveSubstanceConsumed(evt.staticData.GetID());
        if system.GetMaxdocConsumed() >= 3 {
             StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.MaxDOCWithdrawalSymptom", 0.0);
             GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_heavy");
             GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);
        }
        LogChannel(n"DEBUG",
            "RED:Addicted once again: MAXdoc ("
            + system.GetMaxdocConsumed()
            + "), BounceBack ("
            + system.GetBouncebackConsumed()
            + "), FR3SH ("
            + system.GetFr3shConsumed()
            + ")");
    }
    // BaseStatusEffectTypes.Housing
    // HousingStatusEffect.Rested
    // weird:
    // OnRested 453514.031250
    // OnRested 496836.750000
    // other: 13h 543832.562500 where 13 * 3600 = 46800
    // another:   590824.750000 if substracted: 46992.1875 which means non-decimals are seconds (decimals probably being microseconds)
    if evt.staticData.GetID() == t"HousingStatusEffect.Rested" {
        let system = GameInstance.GetTimeSystem(this.GetGame());
        LogChannel(n"DEBUG", "OnRested " + ToString(system.GetGameTimeStamp()));
    }
    return output;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectRemoved \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.IsAddictive() {
        LogChannel(n"DEBUG","RED:Addicted:OnStatusEffectRemoved (IsAddictive)");
    }
  return wrappedMethod(evt);
}