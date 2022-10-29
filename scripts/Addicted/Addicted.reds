module Addicted

@if(ModuleExists("Toxicity"))
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"Addicted", "Toxicity ON");
    GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_heavy");
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);
    wrappedMethod();
}

@if(!ModuleExists("Toxicity"))
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannelWarning(n"Addicted", "Toxicity OFF");
    wrappedMethod();
}