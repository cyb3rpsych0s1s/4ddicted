# Callbacks

Callbacks are another asynchronous mechanism.

🆕 2024/01/28: as a side note callbacks scheduled with `DelaySystem` are only called once, unless manually rescheduled (inside callback's `Call` method for example).

> credits to `DJ_Kovrik`

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
    LogChannel(n"DEBUG", s"Run \(this.sfxName) sfx");
  }
}
```
