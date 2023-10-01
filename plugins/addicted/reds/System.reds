module Addicted

import Addicted.Consumptions
import Addicted.Consumption

public class System extends ScriptableSystem {
    private let player: wref<PlayerPuppet>;
    private persistent let consumptions: ref<Consumptions>;
    private let restingSince: GameTime;
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    private func OnAttach() -> Void {
        if !IsDefined(this.consumptions) {
            let consumptions = new Consumptions();
            consumptions.keys = [];
            consumptions.values = [];
            this.consumptions = consumptions;
        }
    }
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        if IsDefined(request.owner as PlayerPuppet) {
            this.player = request.owner as PlayerPuppet;
        }
    }
    private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
        this.player = null;
    }
    public func RestingSince() -> GameTime { return this.restingSince; }
    public func OnSkipTime() -> Void { this.restingSince = this.TimeSystem().GetGameTime(); }
    // imported in natives
    public func Consumptions() -> ref<Consumptions> { return this.consumptions; }
    public func Player() -> ref<PlayerPuppet> { return this.player; }
    public func TimeSystem() -> ref<TimeSystem> { return GameInstance.GetTimeSystem(this.GetGameInstance()); }
    public func TransactionSystem() -> ref<TransactionSystem> { return GameInstance.GetTransactionSystem(this.GetGameInstance()); }
}
