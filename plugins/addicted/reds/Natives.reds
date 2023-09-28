module Addicted

public native func TestRED4ext(v: Int32) -> Void;
public native func TestSystem(v: ref<System>) -> Void;
public native func Increase(v: ref<Consumption>) -> Void;

public class System extends ScriptableSystem {
    public persistent let dummy: ref<Consumption>;
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    public func HelloWorld() -> Void {
        LogChannel(n"DEBUG", s"Hello World from Addicted.System");
        if !IsDefined(this.dummy) {
            let initial = new Consumption();
            initial.current = 0;
            this.dummy = initial;
        }
        LogChannel(n"DEBUG", s"BEFORE \(this.dummy.current)");
        Increase(this.dummy);
        LogChannel(n"DEBUG", s"AFTER \(this.dummy.current)");
    }
}

public class Consumption extends IScriptable {
    public persistent let current: Int32;
    public func SetCurrent(current: Int32) -> Void { this.current = current; }
    public func GetCurrent() -> Int32 { return this.current; }
}