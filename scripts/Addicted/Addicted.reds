module Addicted

@if(ModuleExists("Toxicity"))
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"Addicted", "Toxicity ON");
    wrappedMethod();
}

@if(!ModuleExists("Toxicity"))
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannelWarning(n"Addicted", "Toxicity OFF");
    wrappedMethod();
}
