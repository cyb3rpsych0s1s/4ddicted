module Addicted.System

import Addicted.Utils.*
import Addicted.*
import Addicted.Helpers.*
import Addicted.Manager.*
import Addicted.Crossover.AlterNeuroBlockerStatusEffects
import Addicted.Crossover.AlterBlackLaceStatusEffects

public class CheckWarnCallback extends DelayCallback {
  public let system: wref<AddictedSystem>;
  public func Call() -> Void {
    this.system.CheckWarn();
  }
}

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
  private let callbackSystem: ref<CallbackSystem>;

  private let config: ref<AddictedConfig>;

  private let onoManager: ref<AudioManager>;
  private let stimulantManager: ref<StimulantManager>;
  private let blacklaceManager: ref<BlackLaceManager>;
  private let alcoholManager: ref<AlcoholManager>;
  private let tobaccoManager: ref<TobaccoManager>;

  private persistent let consumptions: ref<Consumptions>;
  public let restingSince: Float;
  private persistent let lastEnergized: Float;

  private persistent let hasDetoxifierEquipped: Bool;
  private persistent let hasMetabolicEditorEquipped: Bool;

  private let board: wref<IBlackboard>;
  private let quiet: Bool = false;
  private persistent let warned: Bool = false; // deprecated, use warnings instead
  private persistent let warnings: Uint32 = 0u;

  private let updateSymtomsID: DelayID;
  private let healingRechargeDurationModifier: ref<gameStatModifierData>;

  private func RefreshStats(player: ref<PlayerPuppet>) -> Void {
    let stats = GameInstance.GetStatsSystem(player.GetGame());
    let soi = Cast<StatsObjectID>(player.GetEntityID());
    this.hasDetoxifierEquipped = stats
      .GetStatValue(soi, gamedataStatType.HasToxicCleanser) >= 1.0;
    this.hasMetabolicEditorEquipped = stats
      .GetStatValue(soi, gamedataStatType.HasMetabolicEnhancer) >= 1.0;
  }

  private func RegisterListeners(player: ref<PlayerPuppet>) -> Void {
    this.stimulantManager = new StimulantManager();
    this.stimulantManager.Register(player);

    this.blacklaceManager = new BlackLaceManager();
    this.blacklaceManager.Register(player);

    this.alcoholManager = new AlcoholManager();
    this.alcoholManager.Register(player);

    this.tobaccoManager = new TobaccoManager();
    this.tobaccoManager.Register(player);

    this.onoManager = new AudioManager();
    this.onoManager.Register(player);
  }

  private func UnregisterListeners(player: ref<PlayerPuppet>) -> Void {
    this.onoManager.Unregister(player);
    this.onoManager = null;

    this.stimulantManager.Unregister(player);
    this.stimulantManager = null;
    
    this.blacklaceManager.Unregister(player);
    this.blacklaceManager = null;

    this.alcoholManager.Unregister(player);
    this.alcoholManager = null;

    this.tobaccoManager.Unregister(player);
    this.tobaccoManager = null;
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      E(s"on player attach");
      this.player = player;
      this.delaySystem = GameInstance.GetDelaySystem(this.player.GetGame());
      this.timeSystem = GameInstance.GetTimeSystem(this.player.GetGame());
      this.board = GameInstance.GetBlackboardSystem(this.player.GetGame()).Get(GetAllBlackboardDefs().PlayerStateMachine);

      let callback = new UpdateWithdrawalSymptomsCallback();
      callback.system = this;
      this.updateSymtomsID = this.delaySystem.DelayCallback(callback, 600., true);

      this.RefreshStats(this.player);
      this.RegisterListeners(this.player);

      this.RefreshConfig();
    } else { F(s"no player found!"); }
  }

  public final func OnPlayerDetach(player: ref<PlayerPuppet>) -> Void {
    E(s"on player detach");
    this.UnregisterListeners(this.player);
    this.player = null;
  }

  private func OnAttach() -> Void {
    E(s"on attach system");
    this.callbackSystem = GameInstance.GetCallbackSystem();
    this.callbackSystem.RegisterCallback(n"Session/BeforeSave", this, n"OnPreSave");

    if !IsDefined(this.consumptions) {
      this.consumptions = new Consumptions();
    }

    OnAddictedPostAttach(this);
  }

  private func OnDetach() -> Void {
    E(s"on detach system");
    this.UnregisterListeners(this.player);

    OnAddictedPostDetach(this);
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    E(s"on restored system");
    this.RegisterListeners(this.player);
  }

  private cb func OnPreSave(event: ref<GameSessionEvent>) {
    this.ShrinkDoses();
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
    let consumables = Consumables();
    let withdrawing: Bool = false;
    for consumable in consumables {
      withdrawing = this.NotConsumedRecently(consumable);
      now = Bits.Set(before, EnumInt(consumable), withdrawing);
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

  private func CalculateConsumptionModifier(identifier: TweakDBID) -> Float {
    let applied: array<TweakDBID>;
    let stimuli: array<wref<StatModifier_Record>> = [];
    let package: wref<GameplayLogicPackage_Record>;
    let modifier: wref<StatModifier_Record>;
    let id: TweakDBID;
    let i: Int32;

    if !Generic.IsNeuroBlocker(identifier) { return 1.0; }
    let packages = GameInstance.GetGameplayLogicPackageSystem(this.player.GetGame());
    // should NEVER be called DIRECTLY from inside a GameplayLogicPackage (deadlock) 
    packages.GetAppliedPackages(this.player, applied);
    while i < ArraySize(applied) {
      id = applied[i];
      if Equals(id, t"Packages.NeuroStimuliExDisk")
      || Equals(id, t"Packages.NeuroStimuliBioconductor")
      || Equals(id, t"Packages.NeuroStimuliCOX2") {
        package = TweakDBInterface.GetGameplayLogicPackageRecord(id);
        modifier = package.GetStatsItem(0);
        ArrayPush(stimuli, modifier);
      }
      i += 1;
    }
    if ArraySize(stimuli) == 0 { return 1.0; }
    let total: Float = RPGManager
    .CalculateStatModifiers(stimuli, this.player.GetGame(), this.player, Cast<StatsObjectID>(this.player.GetEntityID()));
    if total < 1.0 {
      total = 1.0;
    }
    E(s"total: \(total)");
    return total;
  }

  private func ProcessConsume(itemID: ItemID) -> Consumed {
    let id = ItemID.GetTDBID(itemID);
    let consumed: Consumed;
    let amount: Int32 = 0;
    let hint: Bool = false;
    let before: Threshold = Threshold.Clean;
    let after: Threshold = Threshold.Clean;
    let addictive = Generic.IsAddictive(id);
    let contraindicated = Generic.IsContraindicated(id);
    if addictive || contraindicated {      
      let usedToday = this.DaysSinceLastConsumption(Generic.Consumable(id)) == 0;
      let modifier: Float = this.CalculateConsumptionModifier(id);
      if this.consumptions.KeyExist(itemID) {
        let consumption: ref<Consumption> = this.consumptions.Get(itemID);
        before = Helper.Threshold(consumption.current);
        amount = Min(consumption.current + Helper.Potency(itemID, usedToday, modifier), 100);
      } else {
        before = Threshold.Clean;
        amount = Helper.Potency(itemID, usedToday, modifier);
      }

      after = Helper.Threshold(amount);
      hint = this.Consume(itemID, amount);
    }
    consumed.amount = amount;
    consumed.hint = hint;
    consumed.before = before;
    consumed.after = after;
    return consumed;
  }

  public func OnContraindication(itemID: ItemID) -> Void {
    let id = ItemID.GetTDBID(itemID);
    E(s"contraindicated usage \(TDBID.ToStringDEBUG(id))");

    let consumed: Consumed = this.ProcessConsume(itemID);
    
    if NotEquals(EnumInt(consumed.before), EnumInt(consumed.after)) {
      this.CheckWarn();
    }
  }

  public func OnConsumeItem(itemID: ItemID) -> Void {
    let consumed: Consumed;
    let id = ItemID.GetTDBID(itemID);
    E(s"consume item \(TDBID.ToStringDEBUG(id))");
    if !this.player.PastPrologue() {
      E(s"no consumption tracked during prologue");
      return;
    }
    if Generic.IsAddictive(id) {      
      consumed = this.ProcessConsume(itemID);

      let consumable: Consumable = Generic.Consumable(id);
      if NotEquals(EnumInt(consumable), EnumInt(Consumable.Invalid)) {
        let blackboard: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
        let current = blackboard.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        let next = Bits.Set(current, EnumInt(consumable), false);
        E(s"set \(ToString(consumable)) to false, consumable flags: \(current) -> \(next)");
        blackboard.SetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, next, true);
      } else { F(s"invalid consumable: \(TDBID.ToStringDEBUG(id))"); }

      E(s"consumption hint: \(ToString(consumed.hint))");
      if consumed.hint {
        this.Hint(id);
      }
      if NotEquals(EnumInt(consumed.before), EnumInt(consumed.after)) {
        if Generic.IsHealer(id) { this.UpdateHealingChargeDuration(this.player); }
        this.CheckWarn();
      }
    }
  }

  // HealingItemsRecharge - HealingItemsRechargeDuration (on consumption)
  private func UpdateHealingChargeDuration(player: ref<PlayerPuppet>) -> Void {
    let system = AddictedSystem.GetInstance(player.GetGame());
    let threshold = system.Threshold(Addiction.Healers);
    let serious = Helper.IsSerious(threshold);
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    if serious && !IsDefined(this.healingRechargeDurationModifier) {
      this.healingRechargeDurationModifier = RPGManager.CreateStatModifier(gamedataStatType.HealingItemsRechargeDuration, gameStatModifierType.Multiplier, 0.8);
      stats.AddModifier(Cast<StatsObjectID>(player.GetEntityID()), this.healingRechargeDurationModifier);
    } else if !serious && IsDefined(this.healingRechargeDurationModifier) {
      stats.RemoveModifier(Cast<StatsObjectID>(player.GetEntityID()), this.healingRechargeDurationModifier);
      this.healingRechargeDurationModifier = null;
    }
  }

  public func OnDissipated(id: TweakDBID) -> Void {
    this.Hint(id);
  }

  public func OnRested(id: TweakDBID) -> Void {
    if Effect.IsSleep(id) { this.OnSlept(); }
    else if Effect.IsRefreshed(id) { this.OnRefreshed(); }
  }

  private func OnSlept() -> Void {
    let callback = new UpdateWithdrawalSymptomsCallback();
    callback.system = this;
    this.delaySystem.DelayCallbackNextFrame(callback);

    // apply a slight delay to let V time to stand up
    let check = new CheckWarnCallback();
    check.system = this;
    this.delaySystem.DelayCallback(check, 9., true);
    
    let now = this.timeSystem.GetGameTimeStamp();
    let duration = now - this.restingSince;
    let minimum = 60. * 60. * 6.; // 6h
    let light = duration < minimum;
    if light {
      E(s"not enough sleep ! no wean off");
      return;
    }
    
    let size = this.consumptions.Size();
    if size == 0 { return; }
    let ids = this.consumptions.Items();
    let consumption: ref<Consumption>;
    for id in ids {
      consumption = this.consumptions.Get(id) as Consumption;
      let under_influence = false;
      if this.IsHard() {
        under_influence = this.SleptUnderInfluence(id) && !this.hasDetoxifierEquipped;
        if under_influence
        { 
          E(s"slept under influence, no weaning off for \(TDBID.ToStringDEBUG(ItemID.GetTDBID(id)))");
        }
      }
      if !under_influence {
        if consumption.current > 0 {
          let current = consumption.current;
          let daysSinceLastUsed = this.DaysSinceLastConsumption(Generic.Consumable(id));
          let next = Max(current - Helper.Resilience(id, daysSinceLastUsed) - this.player.CyberwareImmunity(), 0);
          consumption.current = next;
          E(s"slept well, weaning off \(ToString(current)) -> \(ToString(next)) for \(TDBID.ToStringDEBUG(ItemID.GetTDBID(id)))");
        } else {
          this.consumptions.Remove(id);
          E(s"clean again from \(TDBID.ToStringDEBUG(ItemID.GetTDBID(id)))");
        }
      }
    }
  }

  private func OnRefreshed() -> Void {
    let now = this.timeSystem.GetGameTimeStamp();
    let duration = now - this.lastEnergized;
    let minimum = 60. * 60. * 24.; // 24h
    let less_than_a_day = duration < minimum;
    this.lastEnergized = now;
    if less_than_a_day {
      E(s"refreshed bonus only applies once a day");
      return;
    }
    
    let size = this.consumptions.Size();
    if size == 0 { return; }
    let ids = this.consumptions.Items();
    let consumption: ref<Consumption>;
    for id in ids {
      consumption = this.consumptions.Get(id) as Consumption;
      if consumption.current > 0 {
        let current = consumption.current;
        let next = Max(current - 1, 0);
        consumption.current = next;
        E(s"well refreshed, weaning slightly off \(ToString(current)) -> \(ToString(next)) for \(TDBID.ToStringDEBUG(ItemID.GetTDBID(id)))");
      }
    }
  }

  public func ShrinkDoses() -> Void {
    let consumption: ref<Consumption>;
    let doses: array<Float>;
    let dose: Float;
    let shrinked: array<Float>;
    let count: Int32;
    let idx: Int32;
    let ids = this.consumptions.Items();
    for id in ids {
      consumption = this.consumptions.Get(id);
      doses = consumption.doses;
      count = ArraySize(doses);
      if count > 100 {
        shrinked = [];
        idx = count - 100;
        while idx < count {
          dose = doses[idx];
          ArrayPush(shrinked, dose);
          idx += 1;
        }
        consumption.doses = shrinked;
      }
    }
  }

  public func OnDetoxifierChanged(hasDetoxifier: Bool) -> Void {
    this.hasDetoxifierEquipped = hasDetoxifier;
  }

  public func OnMetabolicEditorChanged(hasMetabolicEditor: Bool) -> Void {
    this.hasMetabolicEditorEquipped = hasMetabolicEditor;
  }

  private func Consume(id: ItemID, amount: Int32) -> Bool {
    E(s"consume");
    let now = this.timeSystem.GetGameTimeStamp();
    if this.consumptions.KeyExist(id) {
      let consumption: ref<Consumption> = this.consumptions.Get(id);
      let old = consumption.current;
      consumption.current = amount;
      ArrayPush(consumption.doses, now);
      EI(id, s"additional consumption \(TDBID.ToStringDEBUG(ItemID.GetTDBID(id))) \(ToString(old)) -> \(ToString(consumption.current))");
      return (amount > old) && Generic.IsInstant(id);
    } else {
      EI(id, s"first time consumption for \(TDBID.ToStringDEBUG(ItemID.GetTDBID(id))) => \(ToString(amount))");
      this.consumptions.Insert(id, Consumption.Create(amount, now));
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
    // let specific = this.consumptions.Get(id);
    let averageThreshold = this.consumptions.Threshold(consumable);
    // let specificThreshold = IsDefined(specific) ? specific.Threshold() : Threshold.Clean;
    let threshold: Threshold;
    // if EnumInt(specificThreshold) >= EnumInt(averageThreshold) {
    //   threshold = specificThreshold;
    // } else {
    //   threshold = averageThreshold;
    // }
    threshold = averageThreshold;
    E(s"consumed \(ToString(consumable))" + "\n" +
      // s"current consumption \(ToString(specific.current))" + "\n" +
      // s"\(ToString(specificThreshold)) addicted (version threshold)" + "\n" +
      s"\(ToString(averageThreshold)) addicted (consumable threshold)"
    );
    let now = this.timeSystem.GetGameTimeStamp();
    let hint = Helper.AppropriateHint(id, threshold, now);
    if IsDefined(hint) {
      this.onoManager.Hint(hint);
    }
  }

  /// warn a player with a biomonitor
  public func Warn() -> Void {
    let customer: ref<Customer> = new Customer();
    customer.FirstName = "V";
    customer.LastName = GetLocalizedTextByKey(n"Mod-Addicted-Unknown");
    customer.Age = "27";
    customer.BloodGroup = GetLocalizedTextByKey(n"Mod-Addicted-Unknown");
    customer.Insurance = "-";

    let symptoms = this.Symptoms();
    let chemicals = this.Chemicals();

    let event: ref<CrossThresholdEvent> = new CrossThresholdEvent();
    event.Customer = customer;
    event.Symptoms = symptoms;
    event.Chemicals = chemicals;
    event.Dismissable = this.AlreadyWarned();
    event.boot = true;

    GameInstance.GetUISystem(this.player.GetGame()).QueueEvent(event);
  }

  public func CheckWarn() -> Void {
    if !this.player.HasBiomonitor() { return; }

    let size = this.consumptions.Size();
    if size == 0 { return; }
    let consumables = Consumables();
    let score: Int32;
    let threshold: Threshold;
    let serious: Bool;
    for consumable in consumables {
      score = this.consumptions.TotalConsumption(consumable);
      threshold = Helper.Threshold(score);
      serious = Helper.IsSerious(threshold);
      if serious {
        this.Warn();
        return;
      }
    }
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

  public func SleptUnderInfluence(id: ItemID) -> Bool {
    if !this.consumptions.KeyExist(id) { return false; }
    let consumption = this.consumptions.Get(id);
    if ArraySize(consumption.doses) == 0 { return false; }
    let last: Float = consumption.LastDose();
    if Equals(last, -1.0) { return false; }
    let difference: Float = this.restingSince - last;
    let maximum = 60. * 60.; // 1h
    return difference < maximum;
  }


  private func DaysSinceLastConsumption(consumable: Consumable) -> Int32 {
    let last: Float = this.consumptions.LastDose(consumable);
    if last == -1.0 { return -1; }
    let tms = this.timeSystem.GetGameTimeStamp();
    let now =  Helper.MakeGameTime(tms);
    let today = GameTime.Days(now);
    let previous = Helper.MakeGameTime(last);
    let previousDay = GameTime.Days(previous);

    return today-previousDay;
  }

  /// if hasn't consumed for a day or more
  private func OverOneDay(last: Float) -> Bool {
    let tms = this.timeSystem.GetGameTimeStamp();
    let now =  Helper.MakeGameTime(tms);
    let today = GameTime.Days(now);
    let previous = Helper.MakeGameTime(last);
    let previousDay = GameTime.Days(previous);
    let yesterday = today - 1;
    let moreThan24Hours = (previousDay == yesterday) && ((GameTime.Hours(now) + (24 - GameTime.Hours(previous))) >= 24);
    let moreThan1Day = today >= (previousDay + 2);
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

  public func NotConsumedRecently(addiction: Addiction) -> Bool {
    let last = this.consumptions.LastDose(addiction);
    if Equals(last, -1.0) { return false; }
    return this.OverOneDay(last);
  }

  public func NotConsumedRecently(consumable: Consumable) -> Bool {
    let last = this.consumptions.LastDose(consumable);
    if Equals(last, -1.0) { return false; }
    return this.OverOneDay(last);
  }

  public func AlreadyWarned() -> Bool { return this.warnings > 0u; }
  public func AlreadyWarned(min: Uint32) -> Bool { return this.warnings >= min; }
  public func HighestThreshold() -> Threshold { return this.consumptions.HighestThreshold(); }  

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
    this.Consume(ItemID.FromTDBID(id), amount);
  }

  public func Checkup() -> Void {
    E(s"checkup");
    let size = this.consumptions.Size();
    let ids = this.consumptions.Items();
    if size == 0 {
      E(s"no consumption found!");
      return;
    }
    for id in ids {
      let consumption: ref<Consumption> = this.consumptions.Get(id) as Consumption;
      if IsDefined(consumption) {
        let size = ArraySize(consumption.doses);
        let threshold = Helper.Threshold(consumption.current);
        let consumable = Generic.Consumable(ItemID.GetTDBID(id));
        let withdrawing = this.player.IsWithdrawing(consumable);
        EI(id, s"current: \(ToString(consumption.current)), doses: \(ToString(size)), threshold \(ToString(threshold)), withdrawing \(ToString(withdrawing))");
      } else {
        FI(id, s"consumption found empty");
      }
    }
  }

  public func DebugThresholds() -> Void {
    E(s"debug thresholds:");
    let size = this.consumptions.Size();
    let ids = this.consumptions.Items();
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
    let ids = this.consumptions.Items();
    let withdrawing: Bool;
    let consumable: Consumable;
    for id in ids {
      consumable = Generic.Consumable(ItemID.GetTDBID(id));
      withdrawing = this.player.IsWithdrawing(consumable);
      EI(id, s"withdrawing ? \(withdrawing)");
    }
  }

  public func DebugSetWithdrawing(consumable: Consumable, withdrawing: Bool) -> Void {
    E(s"debug set withdrawing \(ToString(consumable)) -> \(withdrawing)");
    let blackboard: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
    let before = blackboard.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
    let after = Bits.Set(before, EnumInt(consumable), withdrawing);
    blackboard.SetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, after, true);
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

@if(!ModuleExists("ModSettingsModule"))
private func OnAddictedPostAttach(_: ref<AddictedSystem>) -> Void {}
@if(ModuleExists("ModSettingsModule"))
private func OnAddictedPostAttach(system: ref<AddictedSystem>) -> Void { ModSettings.RegisterListenerToModifications(system); }

@if(!ModuleExists("ModSettingsModule"))
private func OnAddictedPostDetach(_: ref<AddictedSystem>) -> Void {}
@if(ModuleExists("ModSettingsModule"))
private func OnAddictedPostDetach(system: ref<AddictedSystem>) -> Void { ModSettings.UnregisterListenerToModifications(system); }

struct Consumed {
  let amount: Int32;
  let hint: Bool;
  let before: Threshold;
  let after: Threshold;
}
