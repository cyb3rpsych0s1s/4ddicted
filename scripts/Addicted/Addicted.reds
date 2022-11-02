module Addicted

@addField(PlayerPuppet)
let consumed: Int32;

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
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "RED:Addicted:OnGameAttached");
    wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.isNewApplication && evt.IsAddictive() {
        this.consumed += 1;
        LogChannel(n"DEBUG","RED:Addicted once again: " + this.consumed);
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

// gamedataStatusEffect_Record :
// <TDBID:7407D72D:20> BaseStatusEffect.FirstAidWhiffV0 (MAXdoc MK.1)
// <TDBID:5D9829EE:1F> BaseStatusEffect.BonesMcCoy70V0 (BounceBack MK.1)

// <TDBID:C28B034A:16> BaseStatusEffect.Sated (after drinking e.g. soda)

// LogChannel(n"DEBUG", "RED:Addicted:OnStatusEffectApplied");
// let someID: TweakDBID = t"BaseStatusEffect.Drugged";
// let moreCommonID: TweakDBID = t"BaseStatusEffect.FirstAidWhiffV0";
// LogChannel(n"DEBUG", s"Its UIData is \(GetLocalizedText(evt.staticData.UiData().DisplayName()))");