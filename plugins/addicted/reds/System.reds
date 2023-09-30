module Addicted

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
    public func TimeSystem() -> ref<TimeSystem> { return GameInstance.GetTimeSystem(this.GetGameInstance()); }
}

public class Consumptions extends IScriptable {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    public func Keys() -> array<TweakDBID> { return this.keys; }
    public func Values() -> array<ref<Consumption>> { return this.values; }
    public func SetKeys(keys: array<TweakDBID>) -> Void { this.keys = keys; }
    public func SetValues(values: array<ref<IScriptable>>) -> Void {
        ArrayClear(this.values);
        this.values = [];
        for value in values {
            ArrayPush(this.values, value as Consumption);
        }
    }
    public func CreateConsumption(score: Int32) -> ref<Consumption> {
        let consumption = new Consumption();
        consumption.current = score;
        consumption.doses = [];
        return consumption;
    }
}
public class Consumption extends IScriptable {
    public persistent let current: Int32;
    public persistent let doses: array<Float>;
    public func Current() -> Int32 { return this.current; }
    public func SetCurrent(value: Int32) -> Void { this.current = value; }
    public func Doses() -> array<Float> { return this.doses; }
    public func SetDoses(value: array<Float>) -> Void { this.doses = value; }
}
