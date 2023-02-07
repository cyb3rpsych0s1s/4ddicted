import Addicted.Utils.E
import Addicted.System.AddictedSystem

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

public class ScreenInteractionEvent extends Event {
    public let Active: Bool;
}

public class CrossThresholdCallback extends DelayCallback {
  private let controller: wref<BiomonitorController>;
  private let event: ref<CrossThresholdEvent>;
  public func Call() -> Void {
    E(s"attempt at warning again");
    controller.OnCrossThresholdEvent(event);
  }
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

    protected cb func OnInitialize() {
        E(s"on initialize controller");
        this.state = BiomonitorState.Idle;
        this.root = this.GetRootWidget() as inkCompoundWidget;
        this.root.SetVisible(false);
        this.waiting = false;
        
        this.booting = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
        let infos       = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas") as inkCompoundWidget;
        E(s"\(ToString(infos))");
        this.firstname  = infos.GetWidget(n"SANDRA_HPanel/Info_SANDRA_Text") as inkText;
        this.lastname   = infos.GetWidget(n"DORSET_HPanel/Info_DORSETT_Text") as inkText;
        this.age        = infos.GetWidget(n"AGE_HPanel/Info_29_Text") as inkText;
        this.blood      = infos.GetWidget(n"BLOOD_HPanel/Info_ABRHD_Text") as inkText;
        this.insurance  = (infos.GetWidgetByIndex(5) as inkHorizontalPanel).GetWidget(n"Info_NC570442_Text") as inkText;

        let row: array<ref<inkWidget>>;
        
        let summary     = infos.GetWidget(n"Critical_Screen_Text_Canvas/inkVerticalPanelWidget7/inkHorizontalPanelWidget2") as inkHorizontalPanel;
        let leftmost    = summary.GetWidget(n"Critical_Vertical") as inkVerticalPanel;
        let center      = summary.GetWidget(n"Critical_Vertical2") as inkVerticalPanel;
        let rightmost   = summary.GetWidget(n"Critical_Vertical_Warning") as inkVerticalPanel;


        E(s"summary: \(ToString(summary))");
        E(s"leftmost: \(ToString(leftmost))");
        E(s"center: \(ToString(center))");
        E(s"rightmost: \(ToString(rightmost))");

        let size = center.GetNumChildren();
        let j = 0;
        let child: ref<inkWidget>;
        while j < size {
            child = center.GetWidgetByIndex(j);
            E(s"name: \(child.GetName()), type: \(ToString(child))");
            j += 1;
        }

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

    protected cb func OnCrossThresholdEvent(evt: ref<CrossThresholdEvent>) -> Bool {
        E(s"on biomonitor event (is already playing ? \(this.animation))");
        if !this.Playing() && this.CanPlay() {
            if this.ShouldWait() {
              if !this.waiting {
                E(s"postponing, there's already another UI ongoing...");
                this.waiting = true;

                let callback: ref<CrossThresholdCallback> = new CrossThresholdCallback();
                callback.controller = this;
                callback.event = evt;

                this.postpone = GameInstance
                .GetDelaySystem(this.GetPlayerControllerObject().GetGame())
                .DelayCallback(callback, 5.);

                return;
              }
            } else {
              if this.waiting {
                GameInstance
                .GetDelaySystem(this.GetPlayerControllerObject().GetGame())
                .CancelCallback(this.postpone);
                this.postpone = GetInvalidDelayID();
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
            return;
        }

        if !this.CanPlay() && this.waiting { this.Reset(); }
    }

    protected cb func OnSkipTimeEvent(evt: ref<SkipTimeEvent>) -> Bool {
        if this.Playing() {
            this.Reset();
        }
    }

    protected cb func OnScreenInteractionEvent(evt: ref<ScreenInteractionEvent>) -> Bool {
        if evt.Active && this.Playing() {
            this.animation.Pause();
            this.waiting = true;
        }
        if !evt.Active && this.Paused() {
            this.animation.Resume();
            this.waiting = false;
        }
    }

    public func ShouldWait() -> Bool {
      let system: ref<BlackboardSystem> = this.GetBlackboardSystem();

      let ui: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().UI_System);
      if IsDefined(ui) {
        let menu: Bool = ui.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
        if menu { return false; }
      }

      let player: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(player) {
        let lore: Bool = player.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInLoreAnimationScene);
        if lore { return false; }
        let interacting: Bool = player.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice);
        if interacting { return false; }
      }

      let data: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().UI_GameData);
      if IsDefined(data) {
        let briefing: Bool = data.GetBool(GetAllBlackboardDefs().UI_GameData.IsBriefingActive);
        if briefing { return false; }
      }

      let photo: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().PhotoMode);
      if IsDefined(photo) {
        let posing: Bool = photo.GetBool(GetAllBlackboardDefs().PhotoMode.Active);
        if posing { return false; }
      }

      return true;
    }

    public func CanPlay() -> Bool {
      let system: ref<BlackboardSystem> = this.GetBlackboardSystem();

      let player: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(player) {
        let dead: Bool = player.GetBool(GetAllBlackboardDefs().PlayerStateMachine.DisplayDeathMenu);
        if dead { return false; }
      }

      // maybe already handled by the game ?
      let travel: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().FastTRavelSystem);
      if IsDefined(travel) {
        let transiting: Bool = travel.GetBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelStarted);
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
            GameObject.PlaySound(this.GetPlayerControlledObject(), n"q001_sandra_biomon_part03");
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
        if NotEquals(this.postpone, GetInvalidDelayID()) {
          GetDelaySystem(this.GetPlayerControlledObject().GetGame()).CancelCallback(this.postpone);
          this.postpone = GetInvalidDelayID();
        }
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
