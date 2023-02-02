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
    private let root: ref<inkCompoundWidget>;
    private let state: BiomonitorState;
    protected cb func OnInitialize() {
        this.state = BiomonitorState.Idle;
        this.root = this.GetRootWidget() as inkCompoundWidget;
        this.root.SetVisible(false);
    }

    private func UpdateBooting() -> Void {
        let panel = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BIOMONITOR_DATA_PANEL_text") as inkText;
        let booting = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        panel.SetText("HELLO WORLD");
        booting.SetText("HELLO WORLD");
    }
    protected cb func OnBiomonitorEvent(evt: ref<BiomonitorEvent>) -> Bool {
        this.root.SetVisible(true);
        this.PlayNext();
    }
    private func PlayNext() -> Bool {
        let options: inkAnimOptions;
        if EnumInt(this.state) == EnumInt(BiomonitorState.Idle) {
            options.fromMarker = n"booting_start";
            options.toMarker = n"booting_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Booting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"currently booting...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Booting) {
            options.executionDelay = 5.;
            options.fromMarker = n"analyzing_start";
            options.toMarker = n"analyzing_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Analyzing;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"analyzing in 5sec...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Analyzing) {
            options.executionDelay = 5.;
            options.fromMarker = n"summarizing_start";
            options.toMarker = n"summarizing_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Summarizing;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"summarizing in 5sec...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Summarizing) {
            options.executionDelay = 5.;
            options.fromMarker = n"contacting_start";
            options.toMarker = n"contacting_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Contacting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"contacting in 5sec...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Contacting) {
            options.executionDelay = 5.;
            options.fromMarker = n"requesting_start";
            options.toMarker = n"requesting_end";
            options.oneSegment = false;
            this.state = BiomonitorState.Requesting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"requesting in 5sec...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Requesting) {
            options.executionDelay = 5.;
            options.fromMarker = n"validating_start";
            options.toMarker = n"validating_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Validating;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"validating in 5sec...");
            return true;
        }
        return false;
    }
    protected cb func OnAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
        // E(s"on animation finished \(ToString(this.state))");
        // E(s">> finished: \(ToString(this.animation.IsFinished())), playing: \(this.animation.IsPlaying()), paused: \(this.animation.IsPaused())");

        let hasNext = this.PlayNext();
        if ! hasNext {
            this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
            this.state = BiomonitorState.Idle;
            E(s"finished all");
        }
    }
}
