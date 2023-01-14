module Addicted.System

import Addicted.Helper

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

  private let hintDelayID: DelayID;

  protected let config: ref<AddictedConfig>;

  private persistent let consumptions: ref<inkHashMap>;
  private persistent let ids: array<TweakDBID>;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(request.owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      this.player = player;
      this.delaySystem = GameInstance.GetDelaySystem(this.player.GetGame());
      this.timeSystem = GameInstance.GetTimeSystem(this.player.GetGame());

      // this.RefreshConfig();
      // this.InvalidateCurrentState();
      // TODO: ...
    }
  }

  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToModifications(this);
  }

  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToModifications(this);
  }

  public func OnModSettingsChange() -> Void {
    // this.RefreshConfig();
    // this.InvalidateCurrentState();
  }
  
  static public func GetInstance(gameInstance: GameInstance) -> ref<AddictedSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(gameInstance);
    return container.Get(n"Addicted.System.AddictedSystem") as AddictedSystem;
  }

  // protected func InvalidateCurrentState() -> Void;
  // protected func RefreshConfig() -> Void;

  public func OnConsumed(id: TweakDBID) -> Void {
    let now = this.timeSystem.GetGameTimeStamp();
    if ArrayContains(this.ids, id) {
      let consumption: wref<Consumption> = this.consumptions.Get(TDBID.ToNumber(id)) as Consumption;
      consumption.current = Min(consumption.current + Helper.Potency(id), 100);
      ArrayPush(consumption.doses, now);
    } else {
      let consumption = new Consumption();
      consumption.current = Helper.Potency(id);
      consumption.doses = [now];
      this.consumptions.Insert(TDBID.ToNumber(id), consumption);
      ArrayPush(this.ids, id);
      this.PublishThreshold();
    }
  }

  public func OnDissipated(id: TweakDBID) -> Void {
    let consumption: wref<Consumption> = this.consumptions.Get(TDBID.ToNumber(id)) as Consumption;
    if IsDefined(consumption) {
      let consumable = Helper.Consumable(id);
      let current = this.AverageConsumption(consumable);
      let threshold = Helper.Threshold(current);
      switch(threshold) {
        case Threshold.Severely:
        case Threshold.Notably:
          let request: ref<PlayUntilRequest>;
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
          request.until = now + RandRangeF(3, 5);
          request.threshold = threshold;
          let delay = RandRangeF(1, 3);
          this.delaySystem.CancelDelay(this.hintDelayID);
          this.hintDelayID = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), request, delay, true);
          break;
        default:
          break;
      }
    }
  }

  public func OnRested() -> Void {
    let id: TweakDBID;
    let size = ArraySize(this.ids);
    if size == 0 {
      return;
    }
    let i = size - 1;
    while i >= 0 {
      id = this.ids[i];
      let consumption: wref<Consumption> = this.consumptions.Get(TDBID.ToNumber(id)) as Consumption;
      if consumption.current > 0 {
        consumption.current = Max(consumption.current - Helper.Resilience(id), 0);
      } else {
        this.consumptions.Remove(TDBID.ToNumber(id));
        ArrayRemove(this.ids, id);
      }
      i -= 1;
    }
  }

  private final func Reschedule(request: ref<PlayUntilRequest>) -> Void {
    request.times += 1;
    if request.times < 3 {
      this.delaySystem.CancelDelay(this.hintDelayID);
      this.hintDelayID = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), request, 1, true);
    }
  }

  protected final func OnCoughingRequest(request: ref<CoughingRequest>) -> Void {
    this.Reschedule(request);
  }
  protected final func OnVomitingRequest(request: ref<VomitingRequest>) -> Void {
    this.Reschedule(request);
  }
  protected final func OnAchingRequest(request: ref<AchingRequest>) -> Void {
    this.Reschedule(request);
  }

  public func Consumption(id: TweakDBID) -> Int32 {
    let consumption: wref<Consumption> = this.consumptions.Get(TDBID.ToNumber(id)) as Consumption;
    if IsDefined(consumption) {
      return consumption.current;
    }
    return 0;
  }

  public func AverageConsumption(consumable: Consumable) -> Int32 {
    let ids = Helper.Effects(consumable);
    let total = 0;
    let found = 0;
    let consumption: wref<Consumption>;
    for id in ids {
      consumption = this.consumptions.Get(TDBID.ToNumber(id)) as Consumption;
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

  private func PublishThreshold() -> Void {
    let healers = this.Threshold(Addiction.Healers);
    // TODO: blackboard
  }
}