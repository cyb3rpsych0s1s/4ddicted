import Addicted.Utils.E
import Addicted.System.AddictedSystem

// or use cp2077-codeware
@addField(inkWidget)
native let parentWidget: wref<inkWidget>;

@addField(NameplateVisualsLogicController)
private let biomonitorWidget: wref<inkWidget>;

@wrapMethod(NameplateVisualsLogicController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    let root = this.GetRootCompoundWidget().parentWidget.parentWidget.parentWidget;
    this.biomonitorWidget = this.SpawnFromExternal(root, r"base\\gameplay\\gui\\quests\\q001\\biomonitor_overlay.inkwidget", n"Root:BiomonitorController");
    this.biomonitorWidget.SetVisible(false);
}

enum BiomonitorState {
    Idle = 0,
    Booting = 1,
    Analyzing = 2,
    Summarizing = 3,
    Closing = 4,
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
    public let BloodGroup: String;
    public let Insurance: String;
}

public class BiomonitorEvent extends Event {
    public let Customer: ref<Customer>;
    public let Symptoms: array<ref<Symptom>>;
    public let boot: Bool;
}

public class BiomonitorController extends inkGameController {
    private let animation: ref<inkAnimProxy>;
    private let root: ref<inkCompoundWidget>;
    private let state: BiomonitorState;
    private let playing: Bool;

    private let booting: ref<inkText>;
    private let firstname: ref<inkText>;
    private let lastname: ref<inkText>;
    private let age: ref<inkText>;
    private let blood: ref<inkText>;
    private let insurance: ref<inkText>;

    private let topLeftChemicalLabel: ref<inkText>;
    private let topLeftChemicalRatio: ref<inkText>;
    private let topMiddleChemicalLabel: ref<inkText>;
    private let topMiddleChemicalRatio: ref<inkText>;
    private let topRightChemicalLabel: ref<inkText>;
    private let topRightChemicalRatio: ref<inkText>;

    protected cb func OnInitialize() {
        this.playing = false;
        this.state = BiomonitorState.Idle;
        this.root = this.GetRootWidget() as inkCompoundWidget;
        this.root.SetVisible(false);
        
        this.booting = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        let infos = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas") as inkCompoundWidget;
        this.firstname  = infos.GetWidget(n"SANDRA_HPanel/Info_SANDRA_Text") as inkText;
        this.lastname   = infos.GetWidget(n"DORSET_HPanel/Info_DORSETT_Text") as inkText;
        let main        = infos.GetWidget(n"Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas") as inkCompoundWidget;
        this.age        = main.GetWidget(n"AGE_HPanel/Info_29_Text") as inkText;
        this.blood      = main.GetWidget(n"BLOOD_HPanel/Info_ABRHD_Text") as inkText;
        this.insurance  = main.GetWidget(n"BLOOD_HPanel/Info_NC570442_Text") as inkText;
        let top = main.GetWidget(n"Info_Chemical_Information_Canvas/Info_Chemical_Info_Vertical/Info_Chemical_Info_H_Line1");
        this.topLeftChemicalLabel   = top.GetWidget(n"Info_N_HYDROXYZINE_text") as inkText;
        this.topLeftChemicalRatio   = top.GetWidget(n"inkHorizontalPanelWidget2/170/Info_170_text") as inkText;
        this.topMiddleChemicalLabel = top.GetWidget(n"Info_TR2_TRAMADOL_Text") as inkText;
        this.topMiddleChemicalRatio = top.GetWidget(n"inkHorizontalPanelWidget3/720/Info_TR2_TRAMADOL_Text") as inkText;
        this.topRightChemicalLabel  = top.GetWidget(n"Info_DESVENLAFAXINE_Text") as inkText;
        this.topRightChemicalRatio  = top.GetWidget(n"inkHorizontalPanelWidget4/300/Info_DESVENLAFAXINE_Text") as inkText;
        
        this.booting.SetLocalizedText(n"Mod-Addicted-Biomonitor-Booting");
    }

    protected cb func OnBiomonitorEvent(evt: ref<BiomonitorEvent>) -> Bool {
        E(s"on biomonitor event (is already playing ? \(this.playing))");
        if !this.playing {
            this.playing = true;
            this.firstname.SetText(evt.Customer.FirstName);
            this.lastname.SetText(evt.Customer.LastName);
            this.age.SetText(evt.Customer.Age);
            this.blood.SetText(evt.Customer.BloodGroup);
            this.insurance.SetText(evt.Customer.Insurance);

            this.topLeftChemicalLabel.SetText("HELLO WORLD");
            this.topLeftChemicalRatio.SetText("HELLO WORLD");
            this.topMiddleChemicalLabel.SetText("HELLO WORLD");
            this.topMiddleChemicalRatio.SetText("HELLO WORLD");
            this.topRightChemicalLabel.SetText("HELLO WORLD");
            this.topRightChemicalRatio.SetText("HELLO WORLD");

            this.PlayNext(evt.boot);
        }
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
            this.animation.RegisterToCallback(inkanimEventType.OnStart, this, n"OnAnimationStarted");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Booting) || EnumInt(this.state) == EnumInt(BiomonitorState.Idle) {
            options.executionDelay = RandRangeF(0.1, 0.5);
            options.fromMarker = n"analyzing_start";
            options.toMarker = n"analyzing_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Analyzing;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Analyzing) {
            options.executionDelay = 1.5;
            options.fromMarker = n"summarizing_start";
            options.toMarker = n"summarizing_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Summarizing;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return true;
        }
        if EnumInt(this.state) == EnumInt(BiomonitorState.Summarizing) {
            this.state = BiomonitorState.Closing;
            let minimize: ref<inkAnimScale> = new inkAnimScale();
            minimize.SetStartScale(new Vector2(1.0, 1.0));
            minimize.SetEndScale(new Vector2(0.01, 0.01));
            minimize.SetType(inkanimInterpolationType.Linear);
            minimize.SetMode(inkanimInterpolationMode.EasyOut);
            minimize.SetDuration(0.2);
            let fade: ref<inkAnimTransparency> = new inkAnimTransparency();
            fade.SetStartTransparency(1.0);
            fade.SetEndTransparency(0.0);
            fade.SetType(inkanimInterpolationType.Linear);
            fade.SetMode(inkanimInterpolationMode.EasyOut);
            fade.SetDuration(0.3);
            let def: ref<inkAnimDef> = new inkAnimDef();
            def.AddInterpolator(minimize);
            def.AddInterpolator(fade);
            options.executionDelay = 3.0;
            options.oneSegment = true;
            this.animation = this.root.PlayAnimationWithOptions(def, options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return true;
        }
        return false;
    }

    protected cb func OnAnimationStarted(anim: ref<inkAnimProxy>) -> Bool {
        this.root.SetVisible(true);
        this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnStart);
    }

    protected cb func OnAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
        let hasNext = this.PlayNext();
        if !hasNext {
            this.root.SetOpacity(1.0);
            this.root.SetScale(new Vector2(1.0, 1.0));
            this.root.SetVisible(false);
            this.animation.Stop(true);
            this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
            this.state = BiomonitorState.Idle;
            this.playing = false;
            E(s"finished all");
        }
    }
}
