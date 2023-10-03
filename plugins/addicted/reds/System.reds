module Addicted

import Addicted.Consumptions
import Addicted.Consumption
import Codeware.*

native func TestReflection() -> Void;

class ConsumeEvent extends Event {
    let message: String;
    static func Create(message: String) -> ref<ConsumeEvent> {
        let evt: ref<ConsumeEvent> = new ConsumeEvent();
        evt.message = message;
        return evt;
    }
}

class ConsumeCallback extends DelayCallback {
  public let system: wref<System>;
  public let message: String;
  public func Call() -> Void {
    LogChannel(n"DEBUG", s"received callback: \(this.message)");
  }
}

@addMethod(PlayerPuppet)
protected cb func OnConsumeEvent(evt: ref<ConsumeEvent>) -> Void {
    LogChannel(n"DEBUG", s"received event: \(evt.message)");
}

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
        TestReflection();
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
    public func DelaySystem() -> ref<DelaySystem> { return GameInstance.GetDelaySystem(this.GetGameInstance()); }
    public func WithdrawalSymptoms() -> BlackboardID_Uint { return GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms; }
    public func IsConsuming() -> BlackboardID_Bool { return GetAllBlackboardDefs().PlayerStateMachine.IsConsuming; }
    func CreateConsumeEvent(message: String) -> ref<ConsumeEvent> { return ConsumeEvent.Create(message); }
    func CreateConsumeCallback(message: String) -> ref<ConsumeCallback> {
        let callback: ref<ConsumeCallback> = new ConsumeCallback();
        callback.system = this;
        callback.message = message;
        return callback;
    }
}
