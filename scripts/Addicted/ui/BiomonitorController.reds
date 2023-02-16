import Addicted.Utils.E
import Addicted.System.AddictedSystem
import Addicted.Helpers.Bits

// or use cp2077-codeware
@addField(inkWidget)
native let parentWidget: wref<inkWidget>;

@addField(NameplateVisualsLogicController)
private let biomonitorWidget: wref<inkWidget>;

@addField(NameplateVisualsLogicController)
private let biomonitorSpawn: wref<inkAsyncSpawnRequest>;

@wrapMethod(NameplateVisualsLogicController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    let root = this.GetRootCompoundWidget().parentWidget.parentWidget.parentWidget;
    // required because .inkwidget packageData was edited
    this.biomonitorSpawn = this.AsyncSpawnFromExternal(root, r"base\\gameplay\\gui\\quests\\q001\\biomonitor_overlay.inkwidget", n"Root:BiomonitorController", this, n"OnBiomonitorSpawned");
}

@addMethod(NameplateVisualsLogicController)
protected cb func OnBiomonitorSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.biomonitorWidget = widget;
    this.biomonitorWidget.SetVisible(false);
    this.biomonitorSpawn = null;
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
    public let Status: String;
}

public class Customer {
    public let FirstName: String;
    public let LastName: String;
    public let Age: String;
    public let BloodGroup: String;
    public let Insurance: String;
}

public class CrossThresholdEvent extends Event {
    public let Customer: ref<Customer>;
    public let Symptoms: array<ref<Symptom>>;
    public let boot: Bool;
}

public class SkipTimeEvent extends Event {}

public class CrossThresholdCallback extends DelayCallback {
  private let controller: wref<BiomonitorController>;
  private let event: ref<CrossThresholdEvent>;
  public func Call() -> Void {
    E(s"attempt at warning again");
    this.controller.OnCrossThresholdEvent(this.event);
  }
}

enum BiomonitorRestrictions {
    InMenu = 1,
    InRadialWheel = 2,
    InQuickHackPanel = 3,
    InPhotoMode = 4,
}

public class BiomonitorController extends inkGameController {
    private let animation: ref<inkAnimProxy>;
    private let root: ref<inkCompoundWidget>;
    private let state: BiomonitorState;
    private let waiting: Bool;

    private let booting: ref<inkText>;
    private let firstname: ref<inkText>;
    private let lastname: ref<inkText>;
    private let age: ref<inkText>;
    private let blood: ref<inkText>;
    private let insurance: ref<inkText>;
    private let vitals: array<array<ref<inkWidget>>>;

    private let postpone: DelayID;
    private let flags: Int32;

    private let menuListener: ref<CallbackHandle>;
    private let replacerListener: ref<CallbackHandle>;
    private let wheelListener: ref<CallbackHandle>;
    private let hackListener: ref<CallbackHandle>;
    private let photoListener: ref<CallbackHandle>;
    private let travelListener: ref<CallbackHandle>;
    private let deathListener: ref<CallbackHandle>;

    protected cb func OnInitialize() {
        E(s"on initialize controller");

        this.RegisterListeners();

        this.state = BiomonitorState.Idle;
        this.root = this.GetRootWidget() as inkCompoundWidget;
        this.root.SetVisible(false);
        this.waiting = false;
        
        this.booting = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        let infos       = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas") as inkCompoundWidget;
        // E(s"\(ToString(infos))");
        this.firstname  = infos.GetWidget(n"SANDRA_HPanel/Info_SANDRA_Text") as inkText;
        this.lastname   = infos.GetWidget(n"DORSET_HPanel/Info_DORSETT_Text") as inkText;
        this.age        = infos.GetWidget(n"AGE_HPanel/Info_29_Text") as inkText;
        this.blood      = infos.GetWidget(n"BLOOD_HPanel/Info_ABRHD_Text") as inkText;
        this.insurance  = (infos.GetWidgetByIndex(5) as inkHorizontalPanel).GetWidget(n"Info_NC570442_Text") as inkText;

        let report      = infos.GetWidget(n"Info_Chemical_Information_Canvas") as inkCanvas;
        let topLine     = report.GetWidget(n"Info_Chemical_Info_Vertical/Info_Chemical_Info_H_Line1") as inkHorizontalPanel;

        let firstSubstance = topLine.GetWidget(n"Info_N_HYDROXYZINE_text") as inkText;
        firstSubstance.SetLocalizationKey(n"Mod-Addicted-Dynorphin");
        let firstValue = topLine.GetWidget(n"inkHorizontalPanelWidget2/170/Info_170_text") as inkText;
        let firstValueController = firstValue.GetController() as inkTextValueProgressController;
        firstValueController.SetBaseValue(22.0);
        firstValueController.SetTargetValue(35.0);

        let row: array<ref<inkWidget>>;
        
        let summary     = infos.GetWidget(n"Critical_Screen_Text_Canvas/inkVerticalPanelWidget7/inkHorizontalPanelWidget2") as inkHorizontalPanel;
        let leftmost    = summary.GetWidget(n"Critical_Vertical") as inkVerticalPanel;
        let center      = summary.GetWidget(n"Critical_Vertical2") as inkVerticalPanel;
        let rightmost   = summary.GetWidget(n"Critical_Vertical_Warning") as inkVerticalPanel;


        // E(s"summary: \(ToString(summary))");
        // E(s"leftmost: \(ToString(leftmost))");
        // E(s"center: \(ToString(center))");
        // E(s"rightmost: \(ToString(rightmost))");

        // let size = center.GetNumChildren();
        // let j = 0;
        // let child: ref<inkWidget>;
        // while j < size {
        //     child = center.GetWidgetByIndex(j);
        //     E(s"name: \(child.GetName()), type: \(ToString(child))");
        //     j += 1;
        // }

        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_BLOOD_PRESSURE_text"));
        ArrayPush(row, center.GetWidgetByIndex(0));
        ArrayPush(row, rightmost.GetWidgetByIndex(0));
        ArrayPush(this.vitals, row);

        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_LEVEL_AO_text"));
        ArrayPush(row, center.GetWidgetByIndex(1));
        ArrayPush(row, rightmost.GetWidgetByIndex(1));
        ArrayPush(this.vitals, row);
        
        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_ALBU_GLOBU_text"));
        ArrayPush(row, center.GetWidgetByIndex(2));
        ArrayPush(row, rightmost.GetWidgetByIndex(2));
        ArrayPush(this.vitals, row);

        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_ESR_text"));
        ArrayPush(row, center.GetWidget(n"Critical_CRITICAL_text"));
        ArrayPush(row, rightmost.GetWidgetByIndex(3));
        ArrayPush(this.vitals, row);

        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_RESPIRATORY_text"));
        ArrayPush(row, center.GetWidget(n"Critical_AT_RISK_text"));
        ArrayPush(row, rightmost.GetWidgetByIndex(4));
        ArrayPush(this.vitals, row);
        
        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_IMMUNE_text"));
        ArrayPush(row, center.GetWidget(n"Critical_AT_RISK2_text"));
        ArrayPush(row, rightmost.GetWidgetByIndex(5));
        ArrayPush(this.vitals, row);

        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_CNS_text"));
        ArrayPush(row, center.GetWidget(n"Critical_AT_RISK3_text"));
        ArrayPush(row, rightmost.GetWidgetByIndex(6));
        ArrayPush(this.vitals, row);
        
        row = [];
        ArrayPush(row, leftmost.GetWidget(n"Critical_PNS_text"));
        ArrayPush(row, center.GetWidget(n"Critical_CRITICAL2_text"));
        ArrayPush(row, rightmost.GetWidgetByIndex(7));
        ArrayPush(this.vitals, row);
        
        this.booting.SetLocalizedText(n"Mod-Addicted-Biomonitor-Booting");
    }

    protected cb func OnUninitialize() {
        E(s"on uninitialize controller");
        this.UnregisterListeners();
    }

    protected func RegisterListeners() -> Void {
        let system: ref<BlackboardSystem> = this.GetBlackboardSystem();
        let definitions: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();

        let state: ref<IBlackboard> = system.Get(definitions.PlayerStateMachine);
        if IsDefined(state) {
            this.deathListener = state.RegisterListenerBool(definitions.PlayerStateMachine.DisplayDeathMenu, this, n"OnDeathMenu");
        }

        let travel: ref<IBlackboard> = system.Get(definitions.FastTRavelSystem);
        if IsDefined(travel) {
            this.travelListener = travel.RegisterListenerBool(definitions.FastTRavelSystem.FastTravelStarted, this, n"OnFastTravel");
        }

        let ui: ref<IBlackboard> = system.Get(definitions.UI_System);
        if IsDefined(ui) {
            this.menuListener = ui.RegisterListenerBool(definitions.UI_System.IsInMenu, this, n"OnInMenu");
            let value: Bool = ui.GetBool(definitions.UI_System.IsInMenu);
            this.flags = Bits.Set(this.flags, EnumInt(BiomonitorRestrictions.InMenu), value);
        }

        let quick: ref<IBlackboard> = system.Get(definitions.UI_QuickSlotsData);
        if IsDefined(quick) {
            this.hackListener = quick.RegisterListenerBool(definitions.UI_QuickSlotsData.quickhackPanelOpen, this, n"OnQuickHackPanel");
            let value: Bool = quick.GetBool(definitions.UI_QuickSlotsData.quickhackPanelOpen);
            this.flags = Bits.Set(this.flags, EnumInt(BiomonitorRestrictions.InQuickHackPanel), value);

            this.wheelListener = quick.RegisterListenerBool(definitions.UI_QuickSlotsData.UIRadialContextRequest, this, n"OnRadialWheel");
            let value: Bool = quick.GetBool(definitions.UI_QuickSlotsData.UIRadialContextRequest);
            this.flags = Bits.Set(this.flags, EnumInt(BiomonitorRestrictions.InRadialWheel), value);
        }

        let stats: ref<IBlackboard> = system.Get(definitions.UI_PlayerStats);
        if IsDefined(stats) {
            this.replacerListener = stats.RegisterListenerBool(definitions.UI_PlayerStats.isReplacer, this, n"OnIsReplacer");
        }

        let photo: ref<IBlackboard> = system.Get(definitions.PhotoMode);
        if IsDefined(photo) {
            this.photoListener = photo.RegisterListenerBool(definitions.PhotoMode.IsActive, this, n"OnPhotoMode");
        }
    }
    protected func UnregisterListeners() -> Void {
        let system: ref<BlackboardSystem> = this.GetBlackboardSystem();
        let definitions: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();

        let state: ref<IBlackboard> = system.Get(definitions.PlayerStateMachine);
        if IsDefined(state) && IsDefined(this.deathListener) {
            state.UnregisterListenerBool(definitions.PlayerStateMachine.DisplayDeathMenu, this.deathListener);
            this.deathListener = null;
        }

        let travel: ref<IBlackboard> = system.Get(definitions.FastTRavelSystem);
        if IsDefined(travel) && IsDefined(this.travelListener) {
            travel.UnregisterListenerBool(definitions.FastTRavelSystem.FastTravelStarted, this.travelListener);
            this.travelListener = null;
        }

        let ui: ref<IBlackboard> = system.Get(definitions.UI_System);
        if IsDefined(ui) && IsDefined(this.menuListener) {
            ui.UnregisterListenerBool(definitions.UI_System.IsInMenu, this.menuListener);
            this.menuListener = null;
        }

        let quick: ref<IBlackboard> = system.Get(definitions.UI_QuickSlotsData);
        if IsDefined(quick) {
            if IsDefined(this.hackListener) {
                quick.UnregisterListenerBool(definitions.UI_QuickSlotsData.quickhackPanelOpen, this.hackListener);
                this.hackListener = null;
            }
            if IsDefined(this.wheelListener) {
                quick.UnregisterListenerBool(definitions.UI_QuickSlotsData.UIRadialContextRequest, this.wheelListener);
                this.wheelListener = null;
            }
        }

        let stats: ref<IBlackboard> = system.Get(definitions.UI_PlayerStats);
        if IsDefined(stats) && IsDefined(this.replacerListener) {
            stats.UnregisterListenerBool(definitions.UI_PlayerStats.isReplacer, this.replacerListener);
            this.replacerListener = null;
        }

        let photo: ref<IBlackboard> = system.Get(definitions.PhotoMode);
        if IsDefined(photo) {
            photo.UnregisterListenerBool(definitions.PhotoMode.IsActive, this.photoListener);
            this.photoListener = null;
        }
    }

    protected cb func OnCrossThresholdEvent(evt: ref<CrossThresholdEvent>) -> Bool {
        E(s"on biomonitor event (is already playing ? \(this.animation))");
        if !this.Playing() && this.CanPlay() {
            if this.ShouldWait() {
              if !this.waiting {
                E(s"postponing, there's already another UI ongoing...");
                this.Reschedule(evt);

                return false;
              }
            } else {
              if this.waiting {
                this.Unschedule();
              }
            }

            this.firstname.SetText(evt.Customer.FirstName);
            this.lastname.SetText(evt.Customer.LastName);
            this.age.SetText(evt.Customer.Age);
            this.blood.SetText(evt.Customer.BloodGroup);
            this.insurance.SetText(evt.Customer.Insurance);

            let i = 0;
            let total = ArraySize(this.vitals);
            let symptom: ref<Symptom>;
            let symptoms: array<ref<Symptom>> = evt.Symptoms;
            let size = ArraySize(symptoms);
            while i < total {
                if i < size {
                    symptom = symptoms[i];
                    E(s"\(ToString(this.vitals[i][0])): \(symptom.Title)");
                    E(s"\(ToString(this.vitals[i][1])): \(symptom.Status)");
                    E(s"\(ToString(this.vitals[i][2])): show");
                    (this.vitals[i][0] as inkText).SetText(symptom.Title);
                    (this.vitals[i][1] as inkText).SetText(symptom.Status);
                    this.vitals[i][0].SetVisible(true);
                    this.vitals[i][1].SetVisible(true);
                    this.vitals[i][2].SetVisible(true);
                } else {
                    E(s"\(ToString(this.vitals[i][0])): empty");
                    E(s"\(ToString(this.vitals[i][1])): empty");
                    E(s"\(ToString(this.vitals[i][2])): hide");
                    this.vitals[i][0].SetVisible(false);
                    this.vitals[i][1].SetVisible(false);
                    this.vitals[i][2].SetVisible(false);
                }
                i += 1;
            }
            E(s"");

            this.PlayNext(evt.boot);
            return false;
        }

        if !this.CanPlay() && this.waiting { this.Reset(); }
    }

    private func Reschedule(event: ref<CrossThresholdEvent>) -> Void {
        E(s"reschedule, there's already another UI ongoing...");
        this.waiting = true;

        let callback: ref<CrossThresholdCallback> = new CrossThresholdCallback();
        callback.controller = this;
        callback.event = event;

        this.postpone = GameInstance
        .GetDelaySystem(this.GetPlayerControlledObject().GetGame())
        .DelayCallback(callback, 5.);
    }

    private func Unschedule() -> Void {
        E(s"unschedule");
        if NotEquals(this.postpone, GetInvalidDelayID()) {
            GameInstance
            .GetDelaySystem(this.GetPlayerControlledObject().GetGame())
            .CancelCallback(this.postpone);
            this.postpone = GetInvalidDelayID();
        }
    }

    protected cb func OnSkipTimeEvent(evt: ref<SkipTimeEvent>) -> Bool {
        E(s"on skip time");
        if this.Playing() {
            this.Reset();
        }
    }

    protected cb func OnDeathMenu(value: Bool) -> Bool {
        E(s"on death menu");
        if value && this.Playing() {
            this.Reset();
        }
    }

    protected cb func OnFastTravel(value: Bool) -> Bool {
        E(s"on fast travel");
        if value && this.Playing() {
            this.Reset();
        }
    }

    protected cb func OnIsReplacer(value: Bool) -> Bool {
        E(s"on player replacer");
        if value && this.Playing() {
            this.Reset();
        }
    }

    protected cb func OnQuickHackPanel(value: Bool) -> Bool {
        if value { E(s"open quick hack panel"); }
        else { E(s"close quick hack panel"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InQuickHackPanel);
    }

    protected cb func OnRadialWheel(value: Bool) -> Bool {
        if value { E(s"open radial wheel"); }
        else { E(s"close radial wheel"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InRadialWheel);
    }

    protected cb func OnInMenu(value: Bool) -> Bool {
        if value { E(s"enter menu"); }
        else { E(s"left menu"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InMenu);
    }

    protected cb func OnPhotoMode(value: Bool) -> Bool {
        if value { E(s"enter photo mode"); }
        else { E(s"left photo mode"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InPhotoMode);
    }

    private func UpdateFlag(value: Bool, flag: BiomonitorRestrictions) -> Void {
        let current : Bool = Bits.Has(this.flags, EnumInt(flag));
        if NotEquals(current, value) {
            this.flags = Bits.Set(this.flags, EnumInt(flag), value);
            this.InvalidateState();
        }
    }

    protected func InvalidateState() -> Void {
        E(s"invalidate state: playing? \(this.Playing()), paused? \(this.Paused()), flags: \(this.flags) (casted \(Cast<Bool>(this.flags)))");
        if this.Playing() && Cast<Bool>(this.flags) {
            E(s"pausing animation");
            this.animation.Pause();
            this.waiting = true;
            return;
        }
        if this.Paused() && !Cast<Bool>(this.flags) {
            E(s"resuming animation");
            this.animation.Resume();
            this.waiting = false;
            return;
        }
    }

    public func ShouldWait() -> Bool {
        return Cast<Bool>(this.flags);
    }

    public func CanPlay() -> Bool {
        let system: ref<BlackboardSystem> = this.GetBlackboardSystem();
        let definitions: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();

        let player: ref<IBlackboard> = system.Get(definitions.PlayerStateMachine);
        if IsDefined(player) {
            let dead: Bool = player.GetBool(definitions.PlayerStateMachine.DisplayDeathMenu);
            if dead { return false; }
        }

        // maybe already handled by the game ?
        let travel: ref<IBlackboard> = system.Get(definitions.FastTRavelSystem);
        if IsDefined(travel) {
            let transiting: Bool = travel.GetBool(definitions.FastTRavelSystem.FastTravelStarted);
            if transiting { return false; }
        }

        return true;
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
            if (this.GetPlayerControlledObject() as PlayerPuppet).IsInCombat() {
                let gender: CName = (this.GetPlayerControlledObject() as ScriptedPuppet).GetResolvedGenderName();
                let ono: CName;
                if Equals(gender, n"Male") {
                    ono = n"ono_freak_m_bump_set_05";
                } else {
                    ono = n"ono_freak_f_bump_set";
                }
                GameObject.PlaySound(this.GetPlayerControlledObject(), ono);
            }
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
            options.executionDelay = 4.0;
            options.oneSegment = true;
            if !(this.GetPlayerControlledObject() as PlayerPuppet).IsInCombat() {
                let onos: array<CName> = [n"ono_v_greet", n"ono_v_curious"];
                let ono: CName = onos[RandRange(0,1)];
                GameObject.PlaySound(this.GetPlayerControlledObject(), ono);
            }
            this.animation = this.root.PlayAnimationWithOptions(def, options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            return true;
        }
        return false;
    }

    protected cb func OnAnimationStarted(anim: ref<inkAnimProxy>) -> Bool {
        this.root.SetVisible(true);
        anim.UnregisterFromAllCallbacks(inkanimEventType.OnStart);
    }

    protected cb func OnAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
        let hasNext = this.PlayNext();
        if !hasNext {
            this.Reset();
            E(s"finished all");
        }
    }

    private func Reset() -> Void {
        this.Unschedule();
        GameObject.StopSound(this.GetPlayerControlledObject(), n"q001_sandra_biomon_part03");
        this.root.SetOpacity(1.0);
        this.root.SetScale(new Vector2(1.0, 1.0));
        this.root.SetVisible(false);
        this.animation.Stop(true);
        this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
        this.state = BiomonitorState.Idle;
        this.waiting = false;
    }

    public func Playing() -> Bool {
        return IsDefined(this.animation) && this.animation.IsPlaying();
    }

    public func Paused() -> Bool {
        return IsDefined(this.animation) && this.animation.IsPaused();
    }
}
