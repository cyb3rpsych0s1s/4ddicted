import Addicted.TestRED4ext
import Addicted.TestSystem
import Addicted.System
public func Pipe(v: Int32) -> Void {
    TestRED4ext(v);
}

// Game.GetPlayer():GetSystem()
@addMethod(PlayerPuppet)
public func GetSystem() -> Void {
    let system: ref<System> = System.GetInstance(this.GetGame());
    system.HelloWorld();
    TestSystem(system);
}
