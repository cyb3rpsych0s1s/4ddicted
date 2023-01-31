import Addicted.Utils.E
import Addicted.System.AddictedSystem

public class BiomonitorController extends inkGameController {
    protected let root: wref<inkWidget>;

    protected let player: wref<GameObject>;

    protected cb func OnInitialize() -> Void {
        E(s"on initialize biomonitor controller");
        this.PlayLibraryAnimation(n"Intro_Loop_Outro"); // Play full original animation
    }

    protected cb func OnUninitialize() -> Bool {}

    private final func RegisterListeners() -> Void {}

    private final func UnregisterListeners() -> Void {}

    protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
        E(s"on player attach biomonitor controller");
        this.player = player;
    }

    protected cb func OnPlayerDetach(player: ref<GameObject>) ->  Bool {
        this.UnregisterListeners();
    }
}

@addField(inkWidget)
native let parentWidget: wref<inkWidget>;

@addField(NameplateVisualsLogicController)
private let biomonitorWidget: wref<inkWidget>;

@addField(NameplateVisualsLogicController)
private let biomonitorController: wref<inkLogicController>;

// @wrapMethod(NameplateVisualsLogicController)
// protected cb func OnInitialize() -> Bool {
//     let root = this.GetRootCompoundWidget() as inkCompoundWidget;
//     E(s"\(root.GetName())");
//     this.biomonitorWidget = this.SpawnFromExternal(root, r"base\\gameplay\\gui\\quests\\q001\\q001_mission0_connect_to_girl.inkwidget", n"ProjectionLogic:BiomonitorController");
//     this.biomonitorController = this.biomonitorWidget.GetController();
//     E(s"on initialize nameplate visuals logic controller");
//     E(s"\(this.biomonitorWidget.GetName()) \(this.biomonitorController.GetClassName())");
//     wrappedMethod();
//     root.SetVisible(true);
//     this.biomonitorWidget.SetVisible(true);
// }

// @wrapMethod(NameplateVisualsLogicController)
// protected cb func OnInitialize() -> Bool {
//     wrappedMethod();
//     let root = this.GetRootWidget();
//     let compound = this.GetRootCompoundWidget();
//     let top = compound.parentWidget.parentWidget.parentWidget;
//     E(s"\(top.GetName())");
//     this.biomonitorWidget = this.SpawnFromExternal(root, r"base\\gameplay\\gui\\quests\\q001\\q001_mission0_connect_to_girl.inkwidget", n"Root:MyController");
//     E(s"on initialize nameplate controller -> root: \(root.GetName()), compound: \(compound.GetName()), spawned: \(this.biomonitorWidget.GetName())");
//     let controllers = this.biomonitorWidget.GetControllers();
//     E(s"\(this.biomonitorWidget.GetClassName())");
//     E(s"has \(this.biomonitorWidget.GetNumControllers()) controller(s)");
//     for controller in controllers {
//         E(s"controller: \(controller.GetClassName())");
//     }
// }

// public class DelayBiomonitorInfos extends DelayCallback {
//     public let owner: wref<MyController>;

// 	public func Call() -> Void {
//         E(s"on delay biomonitor infos callback");
//         let options: inkAnimOptions;
//         options.playReversed = false;
//         options.executionDelay = 0.1;
//         options.loopType = inkanimLoopType.None;
//         options.loopCounter = Cast<Uint32>(0);
//         options.loopInfinite = false;
//         options.fromMarker = n"Arrival";
//         options.toMarker = n"Card_Mask_Canvas";
//         options.oneSegment = false;
//         options.dependsOnTimeDilation = false;
//         this.owner.PlayLibraryAnimation(n"Intro_Loop_Outro", options); // Play full original animation
// 	}
// }

// // Custom controller with your logic
// public class MyController extends inkGameController {
//     private let callback: DelayID;
//     protected cb func OnInitialize() {
//         E(s"on initialize my controller");
//         let system = GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame());
//         let callback = new DelayBiomonitorInfos();
//         callback.owner = this;
//         this.callback = system.DelayCallback(callback, 3., true);
//     }
// }

// Spawn the widget on load
@wrapMethod(NameplateVisualsLogicController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    let root = this.GetRootCompoundWidget().parentWidget.parentWidget.parentWidget;
    this.biomonitorWidget = this.SpawnFromExternal(root, r"base\\gameplay\\gui\\quests\\q001\\biomonitor_overlay.inkwidget", n"Root:MyController");
}

// Custom controller with your logic
public class MyController extends inkGameController {
    protected cb func OnInitialize() {
        let options: inkAnimOptions;
        options.toMarker = n"loading_end";
        let root: ref<inkCompoundWidget> = this.GetRootWidget() as inkCompoundWidget; // Critical_BLOOD_PRESSURE_text
        let panel = root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BIOMONITOR_DATA_PANEL_text") as inkText;
        let booting = root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        panel.SetText("HELLO WORLD");
        booting.SetText("HELLO WORLD");
        
        this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options); // Play full original animation
    }
}
