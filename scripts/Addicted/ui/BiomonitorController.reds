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
    Locating = 7,
    Summoning = 8,
}

enum BloodGroup {
    Unknown = 0,
    A = 1,
    B = 2,
    O = 3,
    AB = 4,
}

public class Symptom {
    public let Title: String;
    public let Description: String;
}

public class Customer {
    public let FirstName: String;
    public let LastName: String;
    public let Age: String;
    public let BloodGroup: BloodGroup;
}

public class BiomonitorEvent extends Event {
    public let Customer: ref<Customer>;
    public let Symptoms: array<ref<Symptom>>;
    public let boot: Bool;
}

// Custom controller with your logic
public class MyController extends inkGameController {
    private let animation: ref<inkAnimProxy>;
    private let root: ref<inkCompoundWidget>;
    private let state: BiomonitorState;

    private let reason: ref<inkText>;
    private let firstname: ref<inkText>;
    private let lastname: ref<inkText>;
    private let age: ref<inkText>;
    private let blood: ref<inkText>;

    protected cb func OnInitialize() {
        this.state = BiomonitorState.Idle;
        this.root = this.GetRootWidget() as inkCompoundWidget;
        this.root.SetVisible(false);
        this.firstname = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas/SANDRA_HPanel/Info_SANDRA_Text") as inkText;
        this.lastname = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas/DORSET_HPanel/Info_DORSETT_Text") as inkText;
        this.age = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas/AGE_HPanel/Info_29_Text") as inkText;
        this.reason = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        this.reason.SetText("HELLO WORLD :)");
    }

    protected cb func OnBiomonitorEvent(evt: ref<BiomonitorEvent>) -> Bool {
        this.firstname.SetText(evt.Customer.FirstName);
        this.lastname.SetText(evt.Customer.LastName);
        this.age.SetText(evt.Customer.Age);
        this.blood.SetText(ToString(evt.Customer.BloodGroup));

        this.root.SetVisible(true);
        this.PlayNext(evt.boot);
    }

    private func PlayNext(opt boot: Bool) -> Bool {
        let options: inkAnimOptions;
        if boot && EnumInt(this.state) == EnumInt(BiomonitorState.Idle) {
            options.fromMarker = n"booting_start";
            options.toMarker = n"booting_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Booting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"currently booting...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Booting) || EnumInt(this.state) == EnumInt(BiomonitorState.Idle) {
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
        //we don't need other steps past it, but for the sake of example ...
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
            options.oneSegment = false; // avoids glitch when meeting original timecode : loop01_start
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
        if EnumInt(this.state) == EnumInt(BiomonitorState.Validating) {
            options.executionDelay = 5.;
            options.fromMarker = n"locating_start";
            options.toMarker = n"locating_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Locating;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"locating in 5sec...");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Locating) {
            options.executionDelay = 5.;
            options.fromMarker = n"summoning_start";
            options.oneSegment = true;
            this.state = BiomonitorState.Summoning;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            E(s"summoning in 5sec...");
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
