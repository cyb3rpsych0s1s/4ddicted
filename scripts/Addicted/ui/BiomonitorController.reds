import Addicted.Utils.E
import Addicted.System.AddictedSystem

@addField(inkWidget)
native let parentWidget: wref<inkWidget>;

@addField(NameplateVisualsLogicController)
private let biomonitorWidget: wref<inkWidget>;

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
        options.fromMarker = n"booting_start";
        options.toMarker = n"booting_end";
        let root: ref<inkCompoundWidget> = this.GetRootWidget() as inkCompoundWidget;
        let panel = root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BIOMONITOR_DATA_PANEL_text") as inkText;
        let booting = root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        panel.SetText("HELLO WORLD");
        booting.SetText("HELLO WORLD");
        
        this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
    }
}
