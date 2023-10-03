module Stupefied

public class System extends ScriptableSystem {
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Stupefied.System") as System;
    }
}