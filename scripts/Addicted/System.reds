module Addicted.System

public class AddictedSystem extends GroupAddictionSystem {
  
  private let player: wref<PlayerPuppet>;
  private let delaySystem: ref<DelaySystem>;

  protected let config: ref<AddictedConfig>;

  protected persistent let addictions: array<ref<Addiction>>;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(request.owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      this.player = player;
      this.delaySystem = GameInstance.GetDelaySystem(this.player.GetGame());

      this.RefreshConfig();
      this.InvalidateCurrentState();
      // TODO: ...
    };
  }

  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToModifications(this);
  }

  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToModifications(this);
  }

  public func OnModSettingsChange() -> Void {
    this.RefreshConfig();
    this.InvalidateCurrentState();
  }
  
  static public func GetInstance(gameInstance: GameInstance) -> ref<AddictedSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(gameInstance);
    return container.Get(n"Addicted.System.AddictedSystem") as AddictedSystem;
  }

  protected func InvalidateCurrentState() -> Void;
  protected func RefreshConfig() -> Void;

  public func OnConsumed(id: TweakDBID) -> Void;
  public func OnDissipated(id: TweakDBID) -> Void;
  public func OnRested() -> Void;
}