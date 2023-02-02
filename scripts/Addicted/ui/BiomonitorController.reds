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

enum BiomonitorState {
    Idle = 0,
    Booting = 1,
    Analyzing = 2,
    Summarizing = 3,
    Contacting = 4,
    Requesting = 5,
    Validating = 6,
}

public class BiomonitorEvent extends Event {}

// Custom controller with your logic
public class MyController extends inkGameController {
    private let animation: ref<inkAnimProxy>;
    private let state: BiomonitorState;
    protected cb func OnInitialize() {
        this.state = BiomonitorState.Idle;
        let options: inkAnimOptions;
        options.fromMarker = n"booting_start";
        options.toMarker = n"booting_end";
        options.oneSegment = true;
        let root: ref<inkCompoundWidget> = this.GetRootWidget() as inkCompoundWidget;
        let panel = root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BIOMONITOR_DATA_PANEL_text") as inkText;
        let booting = root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        panel.SetText("HELLO WORLD");
        booting.SetText("HELLO WORLD");
        
        this.state = BiomonitorState.Booting;
        this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
        this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
    }
    protected cb func OnBiomonitorEvent(evt: ref<BiomonitorEvent>) -> Bool {

    }
    protected cb func OnAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
        E(s"on animation finished \(ToString(this.state))");
        E(s">> finished: \(ToString(this.animation.IsFinished())), playing: \(this.animation.IsPlaying()), paused: \(this.animation.IsPaused())");
        
        E(s"\(ToString(this.GetPlayerControlledObject()))");

        E(s"\(ToString(this.GetPlayerControlledObject().GetGame()))");

        // let event: ref<BiomonitorEvent>;
        // GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(event);

        let options: inkAnimOptions;
        if EnumInt(this.state) == EnumInt(BiomonitorState.Booting) {
            options.fromMarker = n"analyzing_start";
            options.toMarker = n"analyzing_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Analyzing;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return false;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Analyzing) {
            options.fromMarker = n"summarizing_start";
            options.toMarker = n"summarizing_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Summarizing;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return false;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Summarizing) {
            options.fromMarker = n"contacting_start";
            options.toMarker = n"contacting_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Contacting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return false;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Contacting) {
            options.fromMarker = n"requesting_start";
            options.toMarker = n"requesting_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Requesting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return false;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Requesting) {
            options.fromMarker = n"validating_start";
            options.toMarker = n"validating_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Validating;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return false;
        }
        this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
        E(s"finished all");
    }
}
