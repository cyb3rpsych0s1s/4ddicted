module Addicted.System

import Addicted.Utils.*
import Addicted.*

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

  private let config: ref<AddictedConfig>;

  private let hintDelayID: DelayID;
  private let hintSoundEvent: ref<PlaySoundEvent>;

  private persistent let consumptions: ref<Consumptions>;

  private let board: wref<IBlackboard>;
  private let quiet: Bool = false;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      E(s"initialize system on player attach");
      this.player = player;
      this.delaySystem = GameInstance.GetDelaySystem(this.player.GetGame());
      this.timeSystem = GameInstance.GetTimeSystem(this.player.GetGame());
      this.board = this.player.GetPlayerStateMachineBlackboard();

      this.RefreshConfig();
    } else { F(s"no player found!"); }
  }

  private func OnAttach() -> Void {
    E(s"on attach system");
    if !IsDefined(this.consumptions) {
      this.consumptions = new Consumptions();
    }
    ModSettings.RegisterListenerToModifications(this);
  }

  private func OnDetach() -> Void {
    E(s"on detach system");
    ModSettings.UnregisterListenerToModifications(this);
  }

  public func RefreshConfig() -> Void {
    E(s"refresh config");
    this.config = new AddictedConfig();
  }

  public func OnModSettingsChange() -> Void {
    this.RefreshConfig();
  }
  
  public final static func GetInstance(gameInstance: GameInstance) -> ref<AddictedSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(gameInstance);
    return container.Get(n"Addicted.System.AddictedSystem") as AddictedSystem;
  }

  public func OnConsumed(id: TweakDBID) -> Void {
    let std = Helper.EffectBaseName(id);
    if this.consumptions.KeyExist(std) {
      let consumption: ref<Consumption> = this.consumptions.Get(std);
      let amount = Min(consumption.current + Helper.Potency(id), 100);
      this.Consume(std, amount);
    } else {
      this.Consume(std, Helper.Potency(id));
    }
  }

  private func Consume(id: TweakDBID, amount: Int32) -> Void {
    let now = this.timeSystem.GetGameTimeStamp();
    let std = Helper.EffectBaseName(id);
    if this.consumptions.KeyExist(std) {
      let consumption: ref<Consumption> = this.consumptions.Get(std);
      let old = consumption.current;
      let before = Helper.Threshold(old);
      consumption.current = amount;
      let after = Helper.Threshold(consumption.current);
      ArrayPush(consumption.doses, now);
      EI(id, s"additional consumption \(TDBID.ToStringDEBUG(std)) \(ToString(old)) -> \(ToString(consumption.current))");
      if (amount > old) && Helper.IsInstant(id) {
        this.Hint(id);
      }
      if !Equals(EnumInt(before), EnumInt(after)) {
        this.Warn(id, before, after);
      }
    } else {
      EI(id, s"first time consumption for \(TDBID.ToStringDEBUG(std))");
      this.consumptions.Insert(std, Consumption.Create(id, now));
    }
  }

  public func OnRested() -> Void {
    let size = this.consumptions.Size();
    if size == 0 { return; }
    let ids = this.consumptions.Keys();
    let consumption: ref<Consumption>;
    for id in ids {
      consumption = this.consumptions.Get(id) as Consumption;
      if consumption.current > 0 {
        consumption.current = Max(consumption.current - Helper.Resilience(id), 0);
        consumption.doses = consumption.doses;
      } else {
        this.consumptions.Remove(id);
      }
    }
  }

  public func Hint(id: TweakDBID) -> Void {
    if !Equals(this.hintDelayID, GetInvalidDelayID()) { return; }
    let consumption: ref<Consumption> = this.consumptions.Get(id) as Consumption;
    if IsDefined(consumption) {
      let consumable = Helper.Consumable(id);
      let specific = this.consumptions.Get(id);
      let average = this.AverageConsumption(consumable);
      let specificThreshold = Helper.Threshold(specific.current);
      let averageThreshold = Helper.Threshold(average);
      let threshold: Threshold;
      if EnumInt(specificThreshold) >= EnumInt(averageThreshold) {
        threshold = specificThreshold;
      } else {
        threshold = averageThreshold;
      }
      EI(id, s"consumable: \(ToString(consumable)) current: \(ToString(specific)), variant threshold: \(ToString(specificThreshold)), consumable threshold: \(ToString(averageThreshold))");
      if Helper.IsSerious(threshold) {
          let request: ref<HintRequest>;
          if Helper.IsInhaler(id) {
            request = new CoughingRequest();
          }
          // anabolic are also pills, but the opposite isn't true
          let anabolic = Helper.IsAnabolic(id);
          let pill = Helper.IsPill(id);
          if anabolic || pill {
            let random = RandRangeF(1, 10);
            let above: Bool;
            if Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) {
              above = random >= 7.;
            } else {
              above = random >= 9.;
            }
            E(s"random: \(random), above: \(above)");
            if anabolic {
              if above {
                request = new VomitingRequest();
              }
              request = new BreatheringRequest();
            } else {
              if above {
                request = new VomitingRequest();
              }
              request = new HeadAchingRequest();
            }
          }
          if Helper.IsInjector(id) {
            request = new AchingRequest();
          }
          let now = this.timeSystem.GetGameTimeStamp();
          request.threshold = threshold;
          EI(id, s"now: \(ToString(now)) until: \(ToString(request.until)) threshold: \(ToString(request.threshold))");
          this.RescheduleHintRequest(request);
      }
    } else {
      FI(id, s"no consumption recorded while just dissipated");
    }
  }

  /// warn a player with a biomonitor
  public func Warn(id: TweakDBID, before: Threshold, after: Threshold) -> Void {
    // avoids meaningless notifications
    if EnumInt(before) == EnumInt(Threshold.Clean) && EnumInt(after) == EnumInt(Threshold.Barely) { return; }
    let toast: SimpleScreenMessage;
    toast.isShown = true;
    toast.isInstant = true;
    toast.duration = 5.;
    let consumable = Helper.Consumable(id);
    if EnumInt(before) < EnumInt(after) {
      toast.message = s"symptoms of addiction detected\nsubstance: \(ToString(consumable))\nthreshold: \(ToString(after))";
    } else {
      E(s"threshold after: \(ToString(after))");
      if EnumInt(after) == 0 {
        toast.message = s"symptoms of addiction gone\nsubstance: \(ToString(consumable))\nthreshold: \(ToString(after))";
      } else {
        toast.message = s"symptoms of addiction in recession\nsubstance: \(ToString(consumable))\nthreshold: \(ToString(after))\nit's getting better, keep this way !";
      }
    }
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(toast), true);
  }

  public func OnDissipated(id: TweakDBID) -> Void {
    EI(id, s"on dissipation");
    this.Hint(id);
  }

  private func RescheduleHintRequest(request: ref<HintRequest>) -> Void {
    if !Equals(this.hintDelayID, GetInvalidDelayID()) {
      this.CancelHintRequest();
    }
    let now = this.timeSystem.GetGameTimeStamp();
    let delay = RandRangeF(3, 5);
    request.until = now + delay + request.TotalTime();
    this.hintDelayID = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), request, delay, true);
  }

  /// play an onomatopea as a hint to the player when reaching notably or severely addicted
  /// also randomly reschedule if in timeframe
  private func ProcessHintRequest(request: ref<HintRequest>) -> Void {
    let can = this.CanPlayOnomatopea();
    if can {
      if !IsDefined(this.hintSoundEvent) {
        this.hintSoundEvent = new PlaySoundEvent();
      }
      let sound = request.Sound();
      this.hintSoundEvent.soundEvent = sound;
      GameObject.PlaySoundEvent(this.player, sound);
      request.times += 1;
    } else {
      request.until += request.Duration() * 1.5;
    }
    let now = this.timeSystem.GetGameTimeStamp();
    E(s"process hint request: can \(ToString(can)), now \(ToString(now)) <= \(ToString(request.until)) (\(ToString(request.times)) times)");
    if (now > request.until) || (request.times >= Cast<Int32>(request.AtMost())) {
      this.CancelHintRequest();
      if IsDefined(this.hintSoundEvent) {
        if request.IsLoop() {
          GameObject.BreakReplicatedEffectLoopEvent(this.player, request.Sound());
        }
      }
      if IsDefined(this.hintSoundEvent) {
        GameObject.StopSoundEvent(this.player, this.hintSoundEvent.soundEvent);
      }
    }
  }

  private func CancelHintRequest() -> Void {
    this.delaySystem.CancelDelay(this.hintDelayID);
    this.delaySystem.CancelCallback(this.hintDelayID);
    this.hintDelayID = GetInvalidDelayID();
  }

  protected final func OnCoughingRequest(request: ref<CoughingRequest>) -> Void {
    E(s"on coughing request");
    this.ProcessHintRequest(request);
  }

  protected final func OnVomitingRequest(request: ref<VomitingRequest>) -> Void {
    E(s"on vomiting request");
    this.ProcessHintRequest(request);
  }

  protected final func OnAchingRequest(request: ref<AchingRequest>) -> Void {
    E(s"on aching request");
    this.ProcessHintRequest(request);
  }

  protected final func OnBreatheringRequest(request: ref<BreatheringRequest>) -> Void {
    E(s"on breathering request");
    this.ProcessHintRequest(request);
  }

  protected final func OnHeadAchingRequest(request: ref<HeadAchingRequest>) -> Void {
    E(s"on headaching request");
    this.ProcessHintRequest(request);
  }

  /// weaken healers efficiency by subtituting them with debuffed ones
  /// this is because actionEffects are immutable
  public func OnProcessHealerEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
    E(s"on process healer effects");
    let idx = 0;
    let action: TweakDBID;
    let threshold: Threshold;
    let consumable: Consumable;
    let average: Int32;
    let id: TweakDBID;
    let groupAverage = this.AverageAddiction(Addiction.Healers);
    let groupThreshold = Helper.Threshold(groupAverage);
    for effect in actionEffects {
      id = effect.GetID();
      consumable = Helper.Consumable(id);
      average = this.AverageConsumption(consumable);
      threshold = Helper.Threshold(average);
      if EnumInt(threshold) < EnumInt(groupThreshold) {
        threshold = groupThreshold;
      }
      action = Helper.ActionEffect(id, threshold);
      if !Equals(action, id) {
        EI(id, s"replace with \(TDBID.ToStringDEBUG(action))");
        let weakened = TweakDBInterface.GetObjectActionEffectRecord(action);
        actionEffects[idx] = weakened;
      }
      idx += 1;
    }
    return actionEffects;
  }

  /// average consumption for a given consumable
  /// each consumable can have one or many versions (e.g maxdoc and bounceback have 3 versions each)
  public func AverageConsumption(consumable: Consumable) -> Int32 {
    let ids = Helper.Effects(consumable);
    let total = 0;
    let found = 0;
    let consumption: wref<Consumption>;
    for id in ids {
      consumption = this.consumptions.Get(id) as Consumption;
      if IsDefined(consumption) {
        total += consumption.current;
        found += 1;
      }
    }
    if found == 0 {
      return 0;
    }
    return total / found;
  }

  /// average consumption for an addiction
  /// a single addiction can be shared by multiple consumables
  public func AverageAddiction(addiction: Addiction) -> Int32 {
    let consumables = Helper.Consumables(addiction);
    let size = ArraySize(consumables);
    let total = 0;
    for consumable in consumables {
      total += this.AverageConsumption(consumable);
    }
    return total / size;
  }

  public func Threshold(addiction: Addiction) -> Threshold {
    let average = this.AverageAddiction(addiction);
    return Helper.Threshold(average);
  }

  /// if hasn't consumed for a day or more
  public func IsWithdrawing(id: TweakDBID) -> Bool {
    let consumption = this.consumptions.Get(id) as Consumption;
    if !IsDefined(consumption) { return false; }
    let doses = consumption.doses;
    let size = ArraySize(doses);
    if size == 0 { return false; }
    let now = this.timeSystem.GetGameTime();
    let today = GameTime.Days(now);
    let first = doses[0];
    let last = this.timeSystem.RealTimeSecondsToGameTime(first);
    let before = GameTime.Days(last);
    let yesterday = today - 1;
    let moreThan24Hours = (before == yesterday) && ((GameTime.Hours(now) + (24 - GameTime.Hours(last))) >= 24);
    let moreThan1Day = today >= (before + 2);
    if moreThan1Day || moreThan24Hours {
      return true;
    }
    return false;
  }

  public func Quiet() -> Void {
    E(s"quiet");
    if IsDefined(this.hintSoundEvent) {
      GameObject.StopSoundEvent(this.player, this.hintSoundEvent.soundEvent);
      this.hintSoundEvent.SetStatusEffect(ESoundStatusEffects.SUPRESS_NOISE);
      E(s"quiet: stop sound and suppress noise");
    }
    this.quiet = true;
    E(s"quiet: true");
  }

  public func Noisy() -> Void {
    E(s"noisy");
    if IsDefined(this.hintSoundEvent) {
      this.hintSoundEvent.SetStatusEffect(ESoundStatusEffects.NONE);
      E(s"noisy: no audio effect");
    }
    this.quiet = false;
    E(s"noisy: false");
  }

  private func CanPlayOnomatopea() -> Bool {
    if this.quiet {
      E(s"cannot play onomatopea: quiet (from consuming)");
      return false;
    }
    let scene = GameInstance.GetSceneSystem(this.player.GetGame());
    let interface = scene.GetScriptInterface();
    let chatting = interface.IsEntityInDialogue(this.player.GetEntityID());
    if chatting {
      E(s"cannot play onomatopea: currently chatting");
      return false;
    }
    let swimming: Int32 = this.board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming);
    if Equals(swimming, EnumInt(gamePSMSwimming.Diving)) {
      E(s"cannot play onomatopea: currently diving");
      return false;
    }
    E(s"can play onomatopea");
    return true;
  }

  public func DebugSwitchThreshold(id: TweakDBID, threshold: Threshold) -> Void {
    let consumption = EnumInt(threshold);
    // always get back clean
    if consumption > 0 {
      // otherwise always cross the threshold
      consumption += 1;
    }
    this.Consume(id, consumption);
  }

  public func DebugThresholds() -> Void {
    E(s"debug thresholds:");
    let size = this.consumptions.Size();
    let ids = this.consumptions.Keys();
    if size == 0 {
      E(s"no consumption found!");
      return;
    }
    for id in ids {
      let consumption: ref<Consumption> = this.consumptions.Get(id) as Consumption;
      if IsDefined(consumption) {
        let size = ArraySize(consumption.doses);
        EI(id, s"current: \(ToString(consumption.current)) doses: \(ToString(size))");
      } else {
        FI(id, s"consumption found empty");
      }
    }
  }

  public func DebugClear() -> Void {
    E(s"clear all consumptions...");
    let size = this.consumptions.Size();
    let ids = this.consumptions.Keys();
    if size == 0 {
      E(s"no consumption found!");
      return;
    } else {
      for id in ids {
        this.consumptions.Remove(id);
      }
      this.consumptions.Clear();
      E(s"consumption cleaned!");
    }
  }
}