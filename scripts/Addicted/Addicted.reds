module Addicted

@addField(PlayerPuppet)
let consumed: Int32;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "Addicted: game attached");
    //GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_heavy");
    //GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);
    wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    LogChannel(n"DEBUG", ToString(evt.instigatorEntityID));
    if evt.isNewApplication {
        this.consumed += 1;
        LogChannel(n"DEBUG","once again: " + this.consumed);
    }
    return wrappedMethod(evt);
}