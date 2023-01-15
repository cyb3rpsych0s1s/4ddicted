module Addicted.System

import Addicted.Utils.*
import Addicted.*

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

  private let config: ref<AddictedConfig>;

  private let hintDelayID: DelayID;

  private persistent let isildur: ref<Consumptions>;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      E(s"initialize system on player attach");
      this.player = player;
      this.delaySystem = GameInstance.GetDelaySystem(this.player.GetGame());
      this.timeSystem = GameInstance.GetTimeSystem(this.player.GetGame());

      this.RefreshConfig();
    } else { F(s"no player found!"); }
  }

  private func OnAttach() -> Void {
    E(s"on attach system");
    if !IsDefined(this.isildur) {
      this.isildur = new Consumptions();
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
    let now = this.timeSystem.GetGameTimeStamp();
    let key = TDBID.ToNumber(id);
    if this.isildur.KeyExist(id) {
      let consumption: ref<Consumption> = this.isildur.Get(id);
      let old = consumption.current;
      consumption.current = Min(old + Helper.Potency(id), 100);
      ArrayPush(consumption.doses, now);
      E(s"additional consumption \(TDBID.ToStringDEBUG(id)) \(ToString(old)) -> \(ToString(consumption.current))");
    } else {
      E(s"first time consumption for \(TDBID.ToStringDEBUG(id)) \(ToString(key))");
      this.isildur.Insert(id, Consumption.Create(id, now));
    }
    if Helper.IsInstant(id) {
      this.OnHint(id);
    }
  }

  public func OnRested() -> Void {
    let size = this.isildur.Size();
    if size == 0 { return; }
    let ids = this.isildur.Keys();
    let key: Uint64;
    let consumption: ref<Consumption>;
    for id in ids {
      key = TDBID.ToNumber(id);
      consumption = this.isildur.Get(id) as Consumption;
      if consumption.current > 0 {
        consumption.current = Max(consumption.current - Helper.Resilience(id), 0);
        consumption.doses = consumption.doses;
      } else {
        this.isildur.Remove(id);
      }
    }
  }

  public func OnHint(id: TweakDBID) -> Bool {
    let consumption: ref<Consumption> = this.isildur.Get(id) as Consumption;
    if IsDefined(consumption) {
      let consumable = Helper.Consumable(id);
      let specific = this.isildur.Get(id);
      let average = this.AverageConsumption(consumable);
      let specificThreshold = Helper.Threshold(specific.current);
      let averageThreshold = Helper.Threshold(average);
      let threshold: Threshold;
      if EnumInt(specificThreshold) >= EnumInt(averageThreshold) {
        threshold = specificThreshold;
      } else {
        threshold = averageThreshold;
      }
      EI(id, s"consumable: \(ToString(consumable)) current: \(ToString(specific)), specific threshold: \(ToString(specificThreshold)), consumable threshold: \(ToString(averageThreshold))");
      if Helper.IsSerious(threshold) {
          let request: ref<HintRequest>;
          if Helper.IsInhaler(id) {
            request = new CoughingRequest();
          }
          if Helper.IsPill(id) {
            request = new VomitingRequest();
          }
          if Helper.IsInjector(id) {
            request = new AchingRequest();
          }
          let now = this.timeSystem.GetGameTimeStamp();
          request.until = now + 30.;
          request.threshold = threshold;
          EI(id, s"now: \(ToString(now)) until: \(ToString(request.until)) threshold: \(ToString(request.threshold))");
          let delay = RandRangeF(1, 3);
          this.delaySystem.CancelDelay(this.hintDelayID);
          this.hintDelayID = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), request, delay, true);
          return true;
      }
    } else {
      FI(id, s"no consumption recorded while just dissipated");
      return false;
    }
  }

  public func OnDissipated(id: TweakDBID) -> Void {
    EI(id, s"on dissipation");
    this.OnHint(id);
  }

  private func ProcessHintRequest(request: ref<HintRequest>) -> Void {
    GameObject.PlaySoundEvent(this.player, request.Sound());
    let now = this.timeSystem.GetGameTimeStamp();
    E(s"request times: \(ToString(request.times))");
    request.times += 1;
    E(s"request times: \(ToString(request.times))");
    E(s"now \(ToString(now)) <= \(ToString(request.until))");
    if now <= request.until && request.times < 3 {
      let delay = RandRangeF(1, 3);
      this.delaySystem.CancelDelay(this.hintDelayID);
      this.hintDelayID = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), request, delay, true);
    }
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

  public func AverageConsumption(consumable: Consumable) -> Int32 {
    let ids = Helper.Effects(consumable);
    let total = 0;
    let found = 0;
    let consumption: wref<Consumption>;
    let key: Uint64;
    for id in ids {
      key = TDBID.ToNumber(id);
      consumption = this.isildur.Get(id) as Consumption;
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

  public func DebugSwitchThreshold(id: TweakDBID, threshold: Threshold) -> Void {
    let now = this.timeSystem.GetGameTimeStamp();
    if this.isildur.KeyExist(id) {
      let consumption: ref<Consumption> = this.isildur.Get(id) as Consumption;
      let old = consumption.current;
      consumption.current = EnumInt(threshold) + 1;
      ArrayPush(consumption.doses, now);
      EI(id, s"update consumption: \(ToString(old)) -> \(ToString(consumption.current))");
    } else {
      EI(id, s"insert consumption");
      let consumption = new Consumption();
      consumption.current = EnumInt(threshold) + 1;
      consumption.doses = [now];
      this.isildur.Insert(id, consumption);
    }
  }

  public func DebugThresholds() -> Void {
    E(s"debug thresholds:");
    let size = this.isildur.Size();
    let ids = this.isildur.Keys();
    if size == 0 {
      E(s"no consumption found!");
      return;
    }
    for id in ids {
      let consumption: ref<Consumption> = this.isildur.Get(id) as Consumption;
      if IsDefined(consumption) {
        let size = ArraySize(consumption.doses);
        EI(id, s"current: \(ToString(consumption.current)) doses: \(ToString(size))");
      } else {
        FI(id, s"consumption found empty");
      }
    }
  }

  public func DebugClear() -> Void {
    E(s"clear all isildur...");
    let size = this.isildur.Size();
    let ids = this.isildur.Keys();
    if size == 0 {
      E(s"no consumption found!");
      return;
    } else {
      let key: Uint64;
      for id in ids {
        key = TDBID.ToNumber(id);
        this.isildur.Remove(id);
      }
      this.isildur.Clear();
      E(s"consumption cleaned!");
    }
  }
}