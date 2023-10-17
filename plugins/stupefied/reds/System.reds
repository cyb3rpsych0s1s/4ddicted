module Stupefied

import Addicted.CrossThresholdEvent
import Addicted.Threshold
import Addicted.System

public class CompanionSystem extends ScriptableSystem {
    private let player: wref<PlayerPuppet>;
    public final static func GetInstance(game: GameInstance) -> ref<CompanionSystem> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Stupefied.CompanionSystem") as CompanionSystem;
    }
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        if IsDefined(request.owner as PlayerPuppet) {
            this.player = request.owner as PlayerPuppet;
            let system = System.GetInstance(this.player.GetGame());
            system.RegisterCallback(this, n"OnCrossThreshold");
        }
    }
    private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
        let system = System.GetInstance(this.player.GetGame());
        system.UnregisterCallback(this, n"OnCrossThreshold");
        this.player = null;
    }
    protected cb func OnCrossThreshold(event: ref<CrossThresholdEvent>) {
        LogChannel(n"DEBUG", s"It's working! thresholds: \(event.Former()) -> \(event.Latter()).");
    }
    public func Player() -> ref<PlayerPuppet> { return this.player; }
}