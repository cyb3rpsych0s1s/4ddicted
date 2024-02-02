# Lifecycle

Certain methods are always called by the engine and can be leveraged to make sure that code is executed at the right time and/or for cleanup.

## On creation / destruction

Scripts

```swift
public class Script extends IScriptable {
  public final func RegisterOwner(owner: ref<GameObject>) -> Void {}
  public final func UnregisterOwner() -> Void {}
}
```

Components

```swift
public class Component extends ScriptableComponent {
  public func OnGameAttach() -> Void {}
  public func OnGameDetach() -> Void {}
}
```

Systems

```swift
public class System extends ScriptableSystem {
  private func OnAttach() -> Void;
  private func OnDetach() -> Void;
}
```

Player

```swift
public class PlayerPuppet extends ScriptedPuppet {
  private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {}
  private final func PlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {}
  protected cb func OnGameAttached() -> Bool {}
  protected cb func OnDetach() -> Bool {}
}
```
