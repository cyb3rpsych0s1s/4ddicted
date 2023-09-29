module Addicted

public class System extends ScriptableSystem {
    private let player: wref<PlayerPuppet>;
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        if IsDefined(request.owner as PlayerPuppet) {
            this.player = request.owner as PlayerPuppet;
        }
    }
    private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
        this.player = null;
    }
}