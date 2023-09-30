module Addicted

public class System extends ScriptableSystem {
    private let player: wref<PlayerPuppet>;
    private persistent let consumptions: ref<Consumptions>;
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
    func Consumptions() -> ref<Consumptions> { return this.consumptions; }
}

public class Consumptions extends IScriptable {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<Consumption>;
    public func Keys() -> array<TweakDBID> { return this.keys; }
    public func Values() -> array<Consumption> { return this.values; }
    public func Persist(keys: array<TweakDBID>, values: array<Consumption>) -> Void {
        this.keys = keys;
        this.values = values;
    }
}
public struct Consumption {
    public persistent let current: Int32;
    public persistent let doses: array<Float>;
    public static final func Create(current: Int32, doses: array<Float>) -> Consumption {
        return new Consumption(current, doses);
    }
}