module Addicted.System

import Addicted.Utils.*
import Addicted.*

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

  private let config: ref<AddictedConfig>;

  private persistent let consumptions: ref<inkHashMap>;
  private persistent let ids: array<TweakDBID>;

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
    if !IsDefined(this.consumptions) {
      E(s"no hashmap yet");
      this.consumptions = new inkHashMap();
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
    if ArrayContains(this.ids, id) {
      let consumption: ref<Consumption> = this.consumptions.Get(key) as Consumption;
      let old = consumption.current;
      consumption.current = Min(consumption.current + Helper.Potency(id), 100);
      ArrayPush(consumption.doses, now);
      E(s"additional consumption \(TDBID.ToStringDEBUG(id)) \(ToString(old)) -> \(ToString(consumption.current))");
    } else {
      E(s"first time consumption for \(TDBID.ToStringDEBUG(id)) \(ToString(key))");
      this.consumptions.Insert(key, Consumption.Create(id, now));
      ArrayPush(this.ids, id);
    }
  }
}