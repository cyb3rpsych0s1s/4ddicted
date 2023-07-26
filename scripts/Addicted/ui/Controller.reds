import Codeware.Localization.*
import Addicted.Utils.E
import Addicted.System.AddictedSystem
import Addicted.Helpers.Bits
import Addicted.Helpers.Translations
import Addicted.Helpers.Feeling
import Addicted.Helper
import Addicted.Threshold
import Addicted.Mood

public class BiomonitorController extends inkGameController {
    private let animation: ref<inkAnimProxy>;
    private let root: ref<inkCompoundWidget>;
    private let state: BiomonitorState;
    private let waiting: Bool;

    private let postpone: DelayID;
    private let beep: DelayID;
    private let flags: Uint32;
    private let dismissable: Bool = false;
    private let dismissed: Bool = false;
    private let shown: Bool = false;

    private let menuListener: ref<CallbackHandle>;
    private let replacerListener: ref<CallbackHandle>;
    private let wheelListener: ref<CallbackHandle>;
    private let hackListener: ref<CallbackHandle>;
    private let photoListener: ref<CallbackHandle>;
    private let travelListener: ref<CallbackHandle>;
    private let deathListener: ref<CallbackHandle>;
    private let interactionsListener: ref<CallbackHandle>;

    protected cb func OnInitialize() {
        E(s"on initialize controller");

        this.RegisterListeners();

        this.state = BiomonitorState.Idle;
        this.root = this.GetRootWidget() as inkCompoundWidget;
        this.root.parentWidget.SetVisible(false);
        this.waiting = false;
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

        let interactions: ref<IBlackboard> = system.Get(definitions.UIInteractions);
        if IsDefined(interactions) {
            this.interactionsListener = interactions.RegisterListenerVariant(definitions.UIInteractions.VisualizersInfo, this, n"OnVisualizersInfo");
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

        let interactions: ref<IBlackboard> = system.Get(definitions.UIInteractions);
        if IsDefined(interactions) {
            interactions.UnregisterListenerVariant(definitions.UIInteractions.VisualizersInfo, this.interactionsListener);
            this.interactionsListener = null;
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

            this.root.SetCustomer(evt);

            if evt.Dismissable {
                E(s"set hub as dismissable");
                this.dismissable = true;
                let interactions = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
                let visualizer: VisualizersInfo = FromVariant<VisualizersInfo>(interactions.GetVariant(GetAllBlackboardDefs().UIInteractions.VisualizersInfo));
                let id: Int32 = visualizer.activeVisId;
                if Equals(id, -1) {
                    this.RequestShowInteractionHub();
                }
            }

            let system: ref<AddictedSystem> = AddictedSystem.GetInstance(this.GetPlayerControlledObject().GetGame()) as AddictedSystem;
            system.NotifyWarning();
            this.PlayNext(evt.boot);
            return false;
        }

        if !this.CanPlay() && this.waiting { this.Reset(); }
    }

    protected cb func OnInteractionHubEvent(evt: ref<InteractionHubEvent>) -> Bool {
        E(s"on interaction hub event");
        if evt.Show {
            this.ShowInteractionHub();
            return true;
        }
        if !evt.Show && this.shown {
            this.HideInteractionHub();
            return true;
        }
    }

    protected cb func OnDismissBiomonitorEvent(evt: ref<DismissBiomonitorEvent>) -> Bool {
        E(s"on dismiss biomonitor");
        let interactions = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
        let visualizer = FromVariant<VisualizersInfo>(interactions.GetVariant(GetAllBlackboardDefs().UIInteractions.VisualizersInfo));
        // there's no way to differentiate if player clicks "F" to dismiss biomon or e.g. to open a door
        // so only request hide if currently shown on screen
        if visualizer.activeVisId == -1001 {
            this.dismissed = true;
            this.HideInteractionHub();
            this.PlayNext(false, true);
        }

    }

    public func Beep() -> Void {
        GameObject.PlaySound(this.GetPlayerControlledObject(), n"test_beep_03");
    }

    private func RequestShowInteractionHub() -> Void {
        let event: ref<InteractionHubEvent> = new InteractionHubEvent();
        event.Show = true;
        GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(event);
    }

    private func RequestHideInteractionHub() -> Void {
        let event: ref<InteractionHubEvent> = new InteractionHubEvent();
        event.Show = false;
        GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(event);
    }

    private func ShowInteractionHub() -> Void {
        E(s"show interaction hub");
        let interactions = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
        let hub = this.CreateInteractionHub();
        let visualizer = this.PrepareVisualizer(hub);
        interactions.SetVariant(GetAllBlackboardDefs().UIInteractions.InteractionChoiceHub, ToVariant(hub), true);
        interactions.SetVariant(GetAllBlackboardDefs().UIInteractions.VisualizersInfo, ToVariant(visualizer), true);
        this.shown = true;
    }

    private func HideInteractionHub() -> Void {
        E(s"hide interaction hub");
        let interactions = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
        let hub = FromVariant<InteractionChoiceHubData>(interactions.GetVariant(GetAllBlackboardDefs().UIInteractions.InteractionChoiceHub));
        if hub.id == -1001 {
            hub.active = false;
            interactions.SetVariant(GetAllBlackboardDefs().UIInteractions.InteractionChoiceHub, ToVariant(hub), true);
        }
        let visualizer = FromVariant<VisualizersInfo>(interactions.GetVariant(GetAllBlackboardDefs().UIInteractions.VisualizersInfo));
        if visualizer.activeVisId == -1001 && ArrayContains(visualizer.visIds, -1001) {
            visualizer.activeVisId = -1;
            visualizer.visIds = [];
            interactions.SetVariant(GetAllBlackboardDefs().UIInteractions.VisualizersInfo, ToVariant(visualizer), true);
        }
        this.shown = false;
    }

    private func CreateInteractionHub() -> InteractionChoiceHubData {
        let wrapper = new ChoiceTypeWrapper();
        ChoiceTypeWrapper.SetType(wrapper, gameinteractionsChoiceType.InnerDialog);
        let dismiss: InteractionChoiceData;
        dismiss.rawInputKey = EInputKey.IK_F;
        dismiss.isHoldAction = false;
        dismiss.localizedName = GetLocalizedTextByKey(n"Mod-Addicted-Dismiss-Biomonitor");
        dismiss.inputAction = n"Choice1";
        dismiss.type = wrapper;
        let hub: InteractionChoiceHubData;
        hub.id = -1001;
        hub.active = true;
        hub.flags = EVisualizerDefinitionFlags.None;
        hub.title =  GetLocalizedTextByKey(n"Mod-Addicted-Dismiss-Biomonitor");
        hub.choices = [dismiss];
        return hub;
    }

    private func PrepareVisualizer(hub: InteractionChoiceHubData) -> VisualizersInfo {
        let visualizer: VisualizersInfo;
        visualizer.activeVisId = hub.id;
        visualizer.visIds = [hub.id];
        return visualizer;
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
        if NotEquals(this.beep, GetInvalidDelayID()) {
            GameInstance
            .GetDelaySystem(this.GetPlayerControlledObject().GetGame())
            .CancelCallback(this.beep);
            this.beep = GetInvalidDelayID();
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
        if value { this.RequestHideInteractionHub(); }
    }

    protected cb func OnRadialWheel(value: Bool) -> Bool {
        if value { E(s"open radial wheel"); }
        else { E(s"close radial wheel"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InRadialWheel);
        if value { this.RequestHideInteractionHub(); }
    }

    protected cb func OnInMenu(value: Bool) -> Bool {
        if value { E(s"enter menu"); }
        else { E(s"left menu"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InMenu);
        if value { this.RequestHideInteractionHub(); }
    }

    protected cb func OnPhotoMode(value: Bool) -> Bool {
        if value { E(s"enter photo mode"); }
        else { E(s"left photo mode"); }
        this.UpdateFlag(value, BiomonitorRestrictions.InPhotoMode);
        if value { this.RequestHideInteractionHub(); }
    }

    protected cb func OnVisualizersInfo(value: Variant) -> Bool {
        if !this.Playing() || !this.dismissable || this.dismissed { return true; }
        let into: VisualizersInfo = FromVariant<VisualizersInfo>(value);
        let requested: Int32 = into.activeVisId;
        E(s"on visualizers info: active visible ID \(requested), shown \(this.shown)");
        if requested != -1 && requested != -1001 && this.shown {
            this.RequestHideInteractionHub();
        }
        if requested == -1 {
            this.RequestShowInteractionHub();
        }
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

    private func Close(delay: Float) -> Bool {
        this.dismissable = false;
        this.RequestHideInteractionHub();

        let options: inkAnimOptions;
        let minimize: ref<inkAnimScale> = new inkAnimScale();
        minimize.SetStartScale(new Vector2(1.0, 1.0));
        minimize.SetEndScale(new Vector2(0.01, 0.01));
        minimize.SetType(inkanimInterpolationType.Linear);
        minimize.SetMode(inkanimInterpolationMode.EasyOut);
        minimize.SetDuration(0.2);
        let fade: ref<inkAnimTransparency> = new inkAnimTransparency();
        fade.SetStartTransparency(1.0);
        fade.SetEndTransparency(0.0);
        fade.SetType(inkanimInterpolationType.Qubic);
        fade.SetMode(inkanimInterpolationMode.EasyOut);
        fade.SetDuration(0.3);
        let def: ref<inkAnimDef> = new inkAnimDef();
        def.AddInterpolator(minimize);
        def.AddInterpolator(fade);
        options.executionDelay = delay;
        options.oneSegment = true;

        if delay > 0.1 {
            if NotEquals(this.beep, GetInvalidDelayID()) {
                GameInstance
                .GetDelaySystem(this.GetPlayerControlledObject().GetGame())
                .CancelCallback(this.beep);
            }
            let callback: ref<ClosingBeepCallback> = new ClosingBeepCallback();
            callback.controller = this;

            this.beep = GameInstance
            .GetDelaySystem(this.GetPlayerControlledObject().GetGame())
            .DelayCallback(callback, delay - 0.1);
        } else {
            this.Beep();
        }
        
        if IsDefined(this.animation) {
            this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
        }
        this.animation = this.root.PlayAnimationWithOptions(def, options);
        this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
        return true;
    }

    private func PlayNext(opt boot: Bool, opt dismiss: Bool) -> Bool {
        let options: inkAnimOptions;
        let reaction: CName;
        let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
        let game: GameInstance = player.GetGame();
        let system: ref<AddictedSystem> = AddictedSystem.GetInstance(game) as AddictedSystem;
        let gender: gamedataGender = Equals(player.GetResolvedGenderName(), n"Female")
            ? gamedataGender.Female
            : gamedataGender.Male;
        let threshold: Threshold = system.HighestThreshold();
        let warnings: Uint32 = system.Warnings();

        if dismiss && NotEquals(EnumInt(this.state), EnumInt(BiomonitorState.Closing)) {
            player = this.GetPlayerControlledObject() as PlayerPuppet;
            this.state = BiomonitorState.Dismissing;
            if player.IsInCombat() {
                E(s">>> trigger reaction when dismissing in combat");
                reaction = Helper.OnDismissInCombat(gender);
                player.Reacts(reaction);
            }
            return this.Close(0.1);
        }
        if Equals(EnumInt(this.state), EnumInt(BiomonitorState.Idle)) {
            GameObject.PlaySound(this.GetPlayerControlledObject(), n"q001_sandra_biomon_part03");
        }
        if boot && EnumInt(this.state) == EnumInt(BiomonitorState.Idle) {
            options.fromMarker = n"booting_start";
            options.toMarker = n"booting_end";
            options.oneSegment = true;
            this.state = BiomonitorState.Booting;
            this.animation = this.PlayLibraryAnimation(n"Biomonitor_Overlay_Intro_Loop_Outro", options);
            this.animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
            this.animation.RegisterToCallback(inkanimEventType.OnStart, this, n"OnAnimationStarted");
            if player.IsInCombat() {
                E(s">>> trigger reaction when booting in combat");
                if Equals(gender, gamedataGender.Female) {
                    reaction = n"ono_freak_f_bump_set";
                } else {
                    reaction = n"ono_freak_m_bump_set_05";
                }
                player.Reacts(reaction);
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
            let closed = this.Close(4.0);
            if !player.IsInCombat() {
                E(s">>> trigger reaction on symptoms summary when not in combat");
                reaction = Helper.OnceWarned(gender, threshold, warnings);
                E(s"warned: \(ToString(warnings)) time(s), highest threshold: \(ToString(threshold)), reaction: \(NameToString(reaction))");
                player.Reacts(reaction);
            }
            return closed;
        }
        return false;
    }

    protected cb func OnAnimationStarted(anim: ref<inkAnimProxy>) -> Bool {
        this.root.parentWidget.SetVisible(true);
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
        this.RequestHideInteractionHub();
        this.Unschedule();
        GameObject.StopSound(this.GetPlayerControlledObject(), n"q001_sandra_biomon_part03");
        this.root.parentWidget.SetVisible(false);
        this.root.SetOpacity(1.0);
        this.root.SetScale(new Vector2(1.0, 1.0));
        this.animation.Stop(true);
        this.animation.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
        this.waiting = false;
        this.dismissed = false;
        this.dismissable = false;
        this.state = BiomonitorState.Idle;
    }

    public func Playing() -> Bool {
        return IsDefined(this.animation) && this.animation.IsPlaying();
    }

    public func Paused() -> Bool {
        return IsDefined(this.animation) && this.animation.IsPaused();
    }
}
