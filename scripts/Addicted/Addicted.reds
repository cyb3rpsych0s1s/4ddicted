module Addicted

@addField(PlayerPuppet)
let consumed: Int32;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "RED:Addicted:OnGameAttached");
    wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    LogChannel(n"DEBUG", "RED:Addicted:OnStatusEffectApplied");
    let druggedID: TweakDBID = t"BaseStatusEffect.Drugged";
    LogChannel(n"DEBUG", s"The status effect is \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    LogChannel(n"DEBUG", s"Its UIData is \(GetLocalizedText(evt.staticData.UiData().DisplayName()))");
    if evt.isNewApplication && evt.staticData.GetID() == druggedID {
        LogChannel(n"DEBUG","RED:Addicted once again: " + this.consumed);
    }
    return wrappedMethod(evt);
}
