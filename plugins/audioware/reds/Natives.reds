native func PlayCustom(mod: String, sfx: String) -> Bool;
native func OnAttachAudioware() -> Void;
native func OnDetachAudioware() -> Void;

public static func DEBUG(message: String) -> Void { LogChannel(n"DEBUG", s"[audioware] \(message)"); }
public static func ASSERT(message: String) -> Void { LogChannel(n"ASSERT", s"[audioware] \(message)"); }

public class Audioware extends ScriptableSystem {
    private func OnAttach() -> Void {
        DEBUG("on attach audioware");
        OnAttachAudioware();
    }
    private func OnDetach() -> Void {
        DEBUG("on detach audioware");
        OnDetachAudioware();
    }
  
    public final static func GetInstance(gameInstance: GameInstance) -> ref<Audioware> {
        let container = GameInstance.GetScriptableSystemsContainer(gameInstance);
        return container.Get(n"Audioware") as Audioware;
    }

    public func PlayCustom() {
        DEBUG("play custom");
        let can = PlayCustom("Addicted", "addicted.fem_v_as_if_I_didnt_know_already");
        if can { DEBUG("successfully played"); } else { DEBUG("couldn't play"); }
    }
}
