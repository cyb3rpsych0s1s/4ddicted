module Addicted.Controller

public class BiomonitorController extends inkHUDGameController {
    protected let root: wref<inkWidget>;

    protected let player: wref<GameObject>;

    protected cb func OnInitialize() -> Void {
        this.PlayLibraryAnimation(n"Intro_Loop_Outro"); // Play full original animation
    }

    protected cb func OnUninitialize() -> Bool {}

    private final func RegisterListeners() -> Void {}

    private final func UnregisterListeners() -> Void {}

    protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
        this.player = player;
    }

    protected cb func OnPlayerDetach(player: ref<GameObject>) ->  Bool {
        this.UnregisterListeners();
    }
}

@wrapMethod(NameplateVisualsLogicController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    let root = this.GetRootCompoundWidget().parentWidget.parentWidget.parentWidget;
    this.SpawnFromExternal(root, r"base\\gameplay\\gui\\quests\\q001\\q001_mission0_connect_to_girl.inkwidget", n"Root:BiomonitorController");
}
