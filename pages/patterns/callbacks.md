# Callbacks

Callbacks are another asynchronous mechanism.

> credits to DJ_Kovrik

```swift
public class EdgerunningSystem extends ScriptableSystem {
  private func PlaySFXDelayed(name: CName, delay: Float) -> Void {
    let callback: ref<PlaySFXCallback> = new PlaySFXCallback();
    callback.sfxName = name;
    callback.player = GetPlayer(this.GetGameInstance());

    GameInstance
      .GetDelaySystem(this.GetGameInstance())
      .DelayCallback(callback, delay);
  }
}

// given the class extends DelayCallback
public class PlaySFXCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let sfxName: CName;
  // its method Call will automatically get called
  public func Call() -> Void {
    GameObject.PlaySoundEvent(this.player, this.sfxName);
    E(s"Run \(this.sfxName) sfx");
  }
}
```
