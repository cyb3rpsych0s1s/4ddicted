module Addicted.System

import Addicted.Utils.*
import Addicted.*
import Addicted.Helpers.*
import Addicted.Manager.*
import Addicted.Crossover.AlterNeuroBlockerStatusEffects
import Addicted.Crossover.AlterBlackLaceStatusEffects

public class UpdateWithdrawalSymptomsCallback extends DelayCallback {
  public let system: wref<AddictedSystem>;
  public func Call() -> Void {
    this.system.OnUpdateWithdrawalSymptoms();
  }
}

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

  private let config: ref<AddictedConfig>;

  private let healerManager: ref<HealerManager>;
  private let onoManager: ref<AudioManager>;
  private let stimulantManager: ref<StimulantManager>;
  private let blacklaceManager: ref<BlackLaceManager>;

  private persistent let consumptions: ref<Consumptions>;
  public let restingSince: Float;

  private persistent let hasBiomonitorEquipped: Bool;
  private persistent let hasDetoxifierEquipped: Bool;
  private persistent let hasMetabolicEditorEquipped: Bool;

  private let board: wref<IBlackboard>;
  private let quiet: Bool = false;
  private persistent let warned: Bool = false;
  private persistent let warnings: Uint32 = 0u;

  private let updateSymtomsID: DelayID;


  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      E(s"initialize system on player attach");
      this.player = player;
      this.delaySystem = GameInstance.GetDelaySystem(this.player.GetGame());
      this.timeSystem = GameInstance.GetTimeSystem(this.player.GetGame());
      this.board = GameInstance.GetBlackboardSystem(this.player.GetGame()).Get(GetAllBlackboardDefs().PlayerStateMachine);

      let callback = new UpdateWithdrawalSymptomsCallback();
      callback.system = this;
      this.updateSymtomsID = this.delaySystem.DelayCallback(callback, 600., true);

      this.stimulantManager = new StimulantManager();
      this.stimulantManager.Register(this.player);

      this.blacklaceManager = new BlackLaceManager();
      this.blacklaceManager.Register(this.player);

      this.onoManager = new AudioManager();
      this.onoManager.Register(this.player);

      this.RefreshConfig();
    } else { F(s"no player found!"); }
  }

  private func OnAttach() -> Void {
    E(s"on attach system");

    if !IsDefined(this.consumptions) {
      this.consumptions = new Consumptions();
    }
    this.healerManager = new HealerManager();
    this.healerManager.Initialize(this);

    // ModSettings.RegisterListenerToModifications(this);
  }

  private func OnDetach() -> Void {
    E(s"on detach system");

    this.onoManager.Unregister(this.player);
    this.onoManager = null;
    
    this.stimulantManager.Unregister(this.player);
    this.stimulantManager = null;
    
    this.blacklaceManager.Unregister(this.player);
    this.blacklaceManager = null;

    this.healerManager = null;

    // ModSettings.UnregisterListenerToModifications(this);
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    E(s"on restored system");

    this.healerManager.Initialize(this);

    this.stimulantManager = new StimulantManager();
    this.stimulantManager.Register(this.player);

    this.blacklaceManager = new BlackLaceManager();
    this.blacklaceManager.Register(this.player);

    this.onoManager = new AudioManager();
    this.onoManager.Register(this.player);
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

  public func OnUpdateWithdrawalSymptoms() -> Void {
    E(s"on update withdrawal symptoms");
    let blackboard: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
    let before = blackboard.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
    let now: Uint32 = 0u;
    let consumables = Helper.Consumables();
    let withdrawing: Bool = false;
    for consumable in consumables {
      withdrawing = this.IsWithdrawing(consumable);
      now = Bits.Set(now, EnumInt(consumable), withdrawing);
    }
    if NotEquals(before, now) {
      blackboard.SetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, now);
    }

    if NotEquals(this.updateSymtomsID, GetInvalidDelayID()) {
      this.delaySystem.CancelCallback(this.updateSymtomsID);
    }
    let callback = new UpdateWithdrawalSymptomsCallback();
    callback.system = this;
    this.updateSymtomsID = this.delaySystem.DelayCallback(callback, 600., true);
  }

  public func OnConsumeItem(itemID: ItemID) -> Void {
    E(s"consume item \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    if !this.player.PastPrologue() {
      E(s"no consumption tracked during prologue");
      return;
    }
    let id = ItemID.GetTDBID(itemID);
    let before: Threshold;
    let after: Threshold;
    let amount: Int32;
    let hint: Bool;
    if Generic.IsAddictive(id) {
      if this.consumptions.KeyExist(id) {
        let consumption: ref<Consumption> = this.consumptions.Get(id);
        before = Helper.Threshold(consumption.current);
        amount = Min(consumption.current + Helper.Potency(id), 100);
        after = Helper.Threshold(amount); 
        hint = this.Consume(id, amount);
      } else {
        before = Threshold.Clean;
        amount = Helper.Potency(id);
        after = Helper.Threshold(amount);
        hint = this.Consume(id, amount);
      }

      let consumable: Consumable = Generic.Consumable(id);
      if NotEquals(EnumInt(consumable), EnumInt(Consumable.Invalid)) {
        let blackboard: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
        let current = blackboard.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        let next = Bits.Set(current, EnumInt(consumable), false);
        E(s"set \(ToString(consumable)) to false, consumable flags: \(current) -> \(next)");
        blackboard.SetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, next, true);
      } else { F(s"invalid consumable: \(TDBID.ToStringDEBUG(id))"); }

      E(s"consumption hint: \(ToString(hint))");
      if hint {
        this.Hint(id);
      }
      if NotEquals(EnumInt(before), EnumInt(after)) {
        this.Warn(id, before, after);
      }
    }
  }

  public func OnDissipated(id: TweakDBID) -> Void {
    let consumption: ref<Consumption> = this.consumptions.Get(id) as Consumption;
    if !IsDefined(consumption) {
      FI(id, s"no consumption recorded while just dissipated");
      return;
    }
    this.Hint(id);
  }

  public func OnRested(id: TweakDBID) -> Void {
    let sleep = Effect.IsSleep(id);
    let now = this.timeSystem.GetGameTimeStamp();
    let duration = now - this.restingSince;
    let minimum = 60. * 60. * 6.; // 6h
    let light = duration < minimum;
    if sleep && light {
      E(s"not enough sleep ! no wean off");
      return;
    }
    
    let size = this.consumptions.Size();
    if size == 0 { return; }
    let ids = this.consumptions.Keys();
    let consumption: ref<Consumption>;
    for id in ids {
      consumption = this.consumptions.Get(id) as Consumption;
      let under_influence = false;
      if this.IsHard() {
        under_influence = this.SleptUnderInfluence(id) && !this.hasDetoxifierEquipped;
        if sleep && under_influence
        { 
          E(s"slept under influence, no weaning off for \(TDBID.ToStringDEBUG(id))");
        }
      }
      if consumption.current > 0 {
        // energized and refreshed are not affected
        if !sleep || !under_influence {
          let current = consumption.current;
          let next = Max(current - Helper.Resilience(id) - this.player.CyberwareImmunity(), 0);
          consumption.current = next;
          if sleep {
            E(s"slept well, weaning off \(ToString(current)) -> \(ToString(next)) for \(TDBID.ToStringDEBUG(id))");
          }
          else
          {
            E(s"energized or refreshed, weaning off \(ToString(current)) -> \(ToString(next)) for \(TDBID.ToStringDEBUG(id))");
          }
        }
      } else {
        this.consumptions.Remove(id);
        E(s"clean again from \(TDBID.ToStringDEBUG(id))");
      }
    }

    let callback = new UpdateWithdrawalSymptomsCallback();
    callback.system = this;
    this.delaySystem.DelayCallbackNextFrame(callback);
  }

  public func OnProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
    if this.healerManager.ContainsHealerStatusEffects(actionEffects) {
      return this.healerManager.AlterHealerStatusEffects(actionEffects);
    }
    if this.blacklaceManager.ContainsBlackLaceStatusEffects(actionEffects) {
      let threshold = this.Threshold(Consumable.BlackLace);
      if EnumInt(threshold) >= EnumInt(Threshold.Notably) {
        return AlterBlackLaceStatusEffects(threshold, actionEffects);
      }
    }
    if this.blacklaceManager.ContainsNeuroBlockerStatusEffects(actionEffects) {
      let threshold = this.Threshold(Consumable.NeuroBlocker);
      if EnumInt(threshold) >= EnumInt(Threshold.Notably) {
        return AlterNeuroBlockerStatusEffects(threshold, actionEffects);
      }
    }
    return actionEffects;
  }

  public func OnBiomonitorChanged(hasBiomonitor: Bool) -> Void {
    this.hasBiomonitorEquipped = hasBiomonitor;
    if hasBiomonitor {
      let size = this.consumptions.Size();
      if size == 0 { return; }
      let threshold: Threshold;
      let consumption: ref<Consumption>;
      let ids = this.consumptions.Keys();
      // if just equipped, trigger warning since V might be already addicted
      // and didn't have a chance previously to get warned about
      for id in ids {
        consumption = this.consumptions.Get(id);
        threshold = Helper.Threshold(consumption.current);
        if Helper.IsSerious(threshold) {
          let lower = Helper.Lower(threshold);
          this.Warn(id, lower, threshold);
        }
      }
    }
  }

  public func OnDetoxifierChanged(hasDetoxifier: Bool) -> Void {
    this.hasDetoxifierEquipped = hasDetoxifier;
  }

  public func OnMetabolicEditorChanged(hasMetabolicEditor: Bool) -> Void {
    this.hasMetabolicEditorEquipped = hasMetabolicEditor;
  }

  private func Consume(id: TweakDBID, amount: Int32) -> Bool {
    E(s"consume");
    let now = this.timeSystem.GetGameTimeStamp();
    if this.consumptions.KeyExist(id) {
      let consumption: ref<Consumption> = this.consumptions.Get(id);
      let old = consumption.current;
      consumption.current = amount;
      ArrayPush(consumption.doses, now);
      EI(id, s"additional consumption \(TDBID.ToStringDEBUG(id)) \(ToString(old)) -> \(ToString(consumption.current))");
      return (amount > old) && Generic.IsInstant(id);
    } else {
      EI(id, s"first time consumption for \(TDBID.ToStringDEBUG(id)) -> \(ToString(amount))");
      this.consumptions.Insert(id, Consumption.Create(id, amount, now));
      return true;
    }
  }

  public func Hint(id: TweakDBID) -> Void {
    E(s"hint");
    if this.player.IsPossessed() {
      E(s"no hint when possessed");
      return;
    }
    let consumable = Generic.Consumable(id);
    let specific = this.consumptions.Get(id);
    let averageThreshold = this.consumptions.Threshold(consumable);
    let specificThreshold = specific.Threshold();
    let threshold: Threshold;
    if EnumInt(specificThreshold) >= EnumInt(averageThreshold) {
      threshold = specificThreshold;
    } else {
      threshold = averageThreshold;
    }
    E(s"consumed \(ToString(consumable))" + "\n" +
      s"current consumption \(ToString(specific.current))" + "\n" +
      s"\(ToString(specificThreshold)) addicted (version threshold)" + "\n" +
      s"\(ToString(averageThreshold)) addicted (consumable threshold)"
    );
    let now = this.timeSystem.GetGameTimeStamp();
    let hint = Helper.AppropriateHint(id, threshold, now);
    if IsDefined(hint) {
      this.onoManager.Hint(hint);
    }
  }

  /// warn a player with a biomonitor
  public func Warn(id: TweakDBID, before: Threshold, after: Threshold) -> Void {
    if !this.player.HasBiomonitor() { return; }
    // avoids meaningless notifications
    if EnumInt(before) == EnumInt(Threshold.Clean) && EnumInt(after) == EnumInt(Threshold.Barely) { return; }

    let customer: ref<Customer> = new Customer();
    customer.FirstName = "V";
    customer.LastName = "UNKNOWN";
    customer.Age = "27";
    customer.BloodGroup = "UNKNOWN";
    customer.Insurance = "-";

    let symptoms = this.Symptoms();
    let chemicals = this.Chemicals();

    let event: ref<CrossThresholdEvent> = new CrossThresholdEvent();
    event.Customer = customer;
    event.Symptoms = symptoms;
    event.Chemicals = chemicals;
    event.Dismissable = this.warned;
    event.boot = true;

    GameInstance.GetUISystem(this.player.GetGame()).QueueEvent(event);

    if this.warnings == 0u && this.warned { this.warnings = 1u; } // retro-compatibility
  }

  public func NotifyWarning() -> Void {
    if this.warnings < 10u {
      this.warnings += 1u;
    }
  }

  public func Warnings() -> Uint32 { return this.warnings; }

  public func DismissBiomonitor() -> Void {
    let event: ref<DismissBiomonitorEvent> = new DismissBiomonitorEvent();
    GameInstance.GetUISystem(this.player.GetGame()).QueueEvent(event);
  }

  public func IsHard() -> Bool { return Equals(EnumInt(this.config.mode), EnumInt(AddictedMode.Hard)); }

  public func UnderInfluence(id: TweakDBID) -> Bool {
    let effect = StatusEffectHelper.GetStatusEffectByID(this.player, id);
    return IsDefined(effect);
  }

  public func SleptUnderInfluence(id: TweakDBID) -> Bool {
    if !this.consumptions.KeyExist(id) { return false; }
    let consumption = this.consumptions.Get(id);
    if ArraySize(consumption.doses) == 0 { return false; }
    let last: Float = ArrayLast(consumption.doses);
    let difference: Float = this.restingSince - last;
    let maximum = 60. * 60.; // 1h
    return difference < maximum;
  }

  /// if hasn't consumed for a day or more
  public func IsWithdrawing(id: TweakDBID) -> Bool {
    let consumption = this.consumptions.Get(id) as Consumption;
    if !IsDefined(consumption) { return false; }
    let doses = consumption.doses;
    let size = ArraySize(doses);
    if size == 0 { return false; }
    let tms = this.timeSystem.GetGameTimeStamp();
    let now =  Helper.MakeGameTime(tms);
    let today = GameTime.Days(now);
    let last = ArrayLast(doses);
    let previous = Helper.MakeGameTime(last);
    let previousDay = GameTime.Days(previous);
    let yesterday = today - 1;
    let moreThan24Hours = (previousDay == yesterday) && ((GameTime.Hours(now) + (24 - GameTime.Hours(previous))) >= 24);
    let moreThan1Day = today >= (previousDay + 2);
    // EI(id, s"size \(size)");
    // EI(id, s"e.g. dose \(doses[0])");
    // EI(id, s"last consumption \(previousDay), today \(today), yesterday \(yesterday)");
    if moreThan1Day || moreThan24Hours {
      return true;
    }
    return false;
  }

  public func Threshold(addiction: Addiction) -> Threshold {
    return this.consumptions.Threshold(addiction);
  }

  public func Threshold(consumable: Consumable) -> Threshold {
    return this.consumptions.Threshold(consumable);
  }

  public func Symptoms() -> array<ref<Symptom>> {
    let symptoms = this.consumptions.Symptoms();
    return symptoms;
  }

  public func Chemicals() -> array<ref<Chemical>> {
    let chemicals = this.consumptions.Chemicals();
    return chemicals;
  }

  public func IsWithdrawing(addiction: Addiction) -> Bool {
    let ids = Helper.Drugs(addiction);
    for id in ids {
      if this.IsWithdrawing(id) {
        return true;
      }
    }
    return false;
  }

  public func IsWithdrawing(consumable: Consumable) -> Bool {
    let effects = Helper.Effects(consumable);
    let item: TweakDBID;
    for effect in effects {
      item = Generic.Designation(effect);
      if this.IsWithdrawing(item) {
        return true;
      }
    }
    return false;
  }

  public func AlreadyWarned() -> Bool { return this.warned; }
  public func AlreadyWarned(min: Uint32) -> Bool { return this.warnings >= min; }

  public func HighestThreshold() -> Threshold { return this.consumptions.HighestThreshold(); }
  public func HighestThreshold(consumable: Consumable) -> Threshold {
    return this.consumptions.HighestThreshold(consumable);
  }

  public func OnSkipTime() -> Void {
    this.restingSince = this.timeSystem.GetGameTimeStamp();

    let event: ref<SkipTimeEvent> = new SkipTimeEvent();
    GameInstance.GetUISystem(this.player.GetGame()).QueueEvent(event);
  }

  public func DebugSwitchThreshold(id: TweakDBID, threshold: Threshold) -> Void {
    let amount = EnumInt(threshold);
    // always get back clean
    if amount != 0 {
      // otherwise always cross the threshold
      amount = amount + 1;
    }
    this.Consume(id, amount);
  }

  public func Checkup() -> Void {
    E(s"checkup");
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
        let threshold = Helper.Threshold(consumption.current);
        let withdrawing = this.IsWithdrawing(id);
        EI(id, s"current: \(ToString(consumption.current)), doses: \(ToString(size)), threshold \(ToString(threshold)), withdrawing \(ToString(withdrawing))");
      } else {
        FI(id, s"consumption found empty");
      }
    }
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
    this.consumptions.Clear();
  }

  public func DebugWithdrawing() -> Void {
    let ids = this.consumptions.Keys();
    let withdrawing: Bool;
    for id in ids {
      withdrawing = this.IsWithdrawing(id);
      EI(id, s"withdrawing ? \(withdrawing)");
    }
  }

  public func DebugSetWithdrawing(consumable: Consumable, withdrawing: Bool) -> Void {
    E(s"debug set withdrawing \(ToString(consumable)) -> \(withdrawing)");
    let blackboard: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
    let before = blackboard.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
    let after = Bits.Set(before, EnumInt(consumable), withdrawing);
    blackboard.SetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, after);
  }

  public func DebugTime() -> Void {
    let timestamp = this.timeSystem.GetGameTimeStamp();

    let gametime = this.timeSystem.GetGameTime();
    let gametime_seconds = GameTime.GetSeconds(gametime);

    let gt = Helper.MakeGameTime(Cast<Float>(gametime_seconds));
    let tms = Helper.MakeGameTime(timestamp);

    E(s"timestamp                           \(timestamp)");
    E(s"gametime seconds                    \(gametime_seconds)");
    E(s"recalculated from timestamp         \(tms)");
    E(s"recalculated from gametime seconds  \(gt)");
  }
}