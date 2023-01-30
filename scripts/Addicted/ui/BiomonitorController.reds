public class BiomonitorGameController extends inkHUDGameController {
    protected let root: wref<inkWidget>;

    protected let player: wref<GameObject>;

    private let animProxy: ref<inkAnimProxy>;

    protected cb func OnInitialize() -> Void {
    }

    protected cb func OnUninitialize() -> Bool {
    }

    private final func RegisterListeners() -> Void {        
    }

    private final func UnregisterListeners() -> Void {
    }

    protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
        this.player = player;
    }

    protected cb func OnPlayerDetach(player: ref<GameObject>) ->  Bool {
        this.UnregisterListeners();
    }
}