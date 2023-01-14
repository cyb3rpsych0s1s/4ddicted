module Addicted.System

import Addicted.Utils.E
import Addicted.Utils.F

public class AddictedSystem extends ScriptableSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;

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
  
  static public func GetInstance(gameInstance: GameInstance) -> ref<AddictedSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(gameInstance);
    return container.Get(n"Addicted.System.AddictedSystem") as AddictedSystem;
  }
}