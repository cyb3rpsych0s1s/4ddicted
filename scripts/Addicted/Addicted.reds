module Addicted

@if(ModuleExists("Toxicity"))
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "Toxicity ON");
    wrappedMethod();
}

@if(!ModuleExists("Toxicity"))
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "Toxicity OFF");
    wrappedMethod();
}
