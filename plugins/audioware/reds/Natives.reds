native func PlayCustom() -> Void;
native func OnAttachAudioware() -> Void;
native func OnDetachAudioware() -> Void;

private func RemoteLogChannel(message: String) -> Void { LogChannel(n"DEBUG", message); }

public class Audioware extends ScriptableSystem {
    private func OnAttach() -> Void {
        LogChannel(n"DEBUG", "[reds] on attach audioware");
        OnAttachAudioware();
    }
    private func OnDetach() -> Void {
        LogChannel(n"DEBUG", "[reds] on detach audioware");
        OnDetachAudioware();
    }
  
    public final static func GetInstance(gameInstance: GameInstance) -> ref<Audioware> {
        let container = GameInstance.GetScriptableSystemsContainer(gameInstance);
        return container.Get(n"Audioware") as Audioware;
    }

    public func PlayCustom() {
        LogChannel(n"DEBUG", "[reds] play custom");
        PlayCustom();
    }
}
