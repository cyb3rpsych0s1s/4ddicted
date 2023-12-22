# Scriptables

`IScriptable` is actually the parent class of most classes, including the ones used in the previous patterns.

Useful to delegate code, e.g. mechanics with [Blackboard](./blackboards.md) interactions:

```swift
public class Controller extends IScriptable {
  private let owner: wref<GameObject>;
  private let delay: DelayID;
  private let definition: ref<BlackboardDefinition>;
  private let listener: ref<CallbackHandle>;
  private let sticker: BlackboardID_Int;

  private final func RegisterBlackboardListeners() -> Void {
    let bb: ref<IBlackboard>;
    let system: ref<BlackboardSystem>;
    if this.m_owner != null {
      system = GameInstance.GetBlackboardSystem(this.m_owner.GetGame());
    };
    if system != null {
      bb = system.GetLocalInstanced(this.m_owner.GetEntityID(), this.definition);
      if bb != null {
        // by registering to board for updates and specifying the method name
        this.listener = bb.RegisterListenerInt(this.sticker, this, n"OnStickerChanged");
      };
    };
  }

  // it will automatically call
  private final func OnStickerChanged(value: Int32) -> Void
  {}

  // of course one need to take care of unregistering too
  public final func RegisterOwner(owner: ref<GameObject>) -> Void {}
  public final func UnregisterOwner() -> Void {}
}

public class PlayerPuppet extends ScriptedPuppet {
  private let controller: ref<Controller>;
  private final func PlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {
    // here controller can be attached (register)
  }
  private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
    // here controller can be detached (unregister/cleanup)
  }
}
```
