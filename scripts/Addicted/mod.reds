module Addicted

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
    if evt.isNewApplication && evt.IsAddictive() {
        let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
        let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
        system.OnAddictiveSubstanceConsumed(evt.staticData.GetID());
        if system.m_maxdocThreshold >= 3 {
            StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.MaxDOCWithdrawalSymptom", 0.0);
        }
        LogChannel(n"DEBUG",
            "RED:Addicted once again: MAXdoc ("
            + system.m_maxdocThreshold
            + "), BounceBack ("
            + system.m_bouncebackThreshold
            + "), FR3SH ("
            + system.m_fr3shThreshold
            + ")");
    }
    return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectRemoved \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.IsAddictive() {
        LogChannel(n"DEBUG","RED:Addicted:OnStatusEffectRemoved (IsAddictive)");
    }
  return wrappedMethod(evt);
}