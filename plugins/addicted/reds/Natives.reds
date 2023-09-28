module Addicted

public native func TestRED4ext(v: Int32) -> Void;

public class System extends ScriptableSystem {
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    public func HelloWorld() -> Void {
        LogChannel(n"DEBUG", s"Hello World from Addicted.System");
    }
}