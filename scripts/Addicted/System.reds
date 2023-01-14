module Addicted.System

import Addicted.Helper

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

  protected let config: ref<AddictedConfig>;

  private persistent let addictions: ref<inkHashMap>;
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
      let consumption: wref<Consumption> = this.addictions.Get(TDBID.ToNumber(id)) as Consumption;
      consumption.current = Min(consumption.current + Helper.Potency(id), 100);
      ArrayPush(consumption.doses, now);
    } else {
      let consumption = new Consumption();
      consumption.current = 1;
      consumption.doses = [now];
      this.addictions.Insert(TDBID.ToNumber(id), consumption);
      ArrayPush(this.ids, id);
    }
  }

  // public func OnDissipated(id: TweakDBID) -> Void;

  public func OnRested() -> Void {
    let id: TweakDBID;
    let size = ArraySize(this.ids);
    if size == 0 {
      return;
    }
    let i = size - 1;
    while i >= 0 {
      id = this.ids[i];
      let consumption: wref<Consumption> = this.addictions.Get(TDBID.ToNumber(id)) as Consumption;
      if consumption.current == 0 {
        consumption.current = Max(consumption.current - Helper.Resilience(id), 0);
      } else {
        this.addictions.Remove(TDBID.ToNumber(id));
        ArrayRemove(this.ids, id);
      }
      i -= 1;
    }
  }
}