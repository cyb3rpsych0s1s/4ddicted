module Stupefied

import Addicted.AddictionEvent
import Addicted.CrossThresholdEvent
import Addicted.ConsumeEvent
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
            system.RegisterCallback(this, n"OnAddictionEvent");
        }
    }
    private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
        let system = System.GetInstance(this.player.GetGame());
        system.UnregisterCallback(this, n"OnAddictionEvent");
        this.player = null;
    }
    protected cb func OnAddictionEvent(event: ref<AddictionEvent>) {
        if event.IsExactlyA(n"Addicted.ConsumeEvent") {
            let consume = event as ConsumeEvent;
            LogChannel(n"DEBUG", s"consumed: \(TDBID.ToStringDEBUG(ItemID.GetTDBID(consume.Item()))): \(consume.Score())");
        } else if event.IsA(n"Addicted.CrossThresholdEvent") {
            let cross = event as CrossThresholdEvent;
            let direction: String = "unknown direction from event";
            if cross.IsExactlyA(n"Addicted.IncreaseThresholdEvent")      { direction = "threshold increase"; }
            else if cross.IsExactlyA(n"Addicted.DecreaseThresholdEvent") { direction = "threshold decrease"; }
            LogChannel(n"DEBUG", s"\(direction) for \(TDBID.ToStringDEBUG(ItemID.GetTDBID(cross.Item()))): \(cross.Former()) -> \(cross.Latter())");
        }
    }
    public func Player() -> ref<PlayerPuppet> { return this.player; }
}