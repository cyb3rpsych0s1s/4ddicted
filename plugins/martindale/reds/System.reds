module Martindale

public class MartindaleSystem extends ScriptableSystem {
    private let registry: ref<Registry>;
    private let callbacks: ref<CallbackSystem>;
    private func OnAttach() -> Void {
        LogChannel(n"DEBUG", "[Martindale.System][OnAttach]");
        this.callbacks = GameInstance.GetCallbackSystem();
        this.callbacks.RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
    }
    private func OnDetach() -> Void {
        if IsDefined(this.callbacks) {
            this.callbacks.UnregisterCallback(n"Session/Ready", this, n"OnSessionReady");
            this.callbacks = null;
        }
        if IsDefined(this.registry) {
            this.registry.Clear();
            this.registry = null;
        }
        LogChannel(n"DEBUG", "[Martindale.System][OnDetach] deleted registry");
    }
    private cb func OnSessionReady(event: ref<GameSessionEvent>) {
        LogChannel(n"DEBUG", "[Martindale.System][OnSessionReady] creating registry...");

        this.registry = new Registry();
        this.registry.Scan();

        LogChannel(n"DEBUG", "[Martindale.System][OnSessionReady] registry created successfully!");
    }
    
    public func DebugRegistry() -> Void {
        this.registry.DebugConsumables();
    }
    public final static func GetInstance(game: GameInstance) -> ref<MartindaleSystem> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Martindale.MartindaleSystem") as MartindaleSystem;
    }
}
