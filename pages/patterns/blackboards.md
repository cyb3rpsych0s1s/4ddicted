# Blackboards

// TODO: DOUBLE CHECK

Blackboards act as a global storage for variables.
Other parts of the code can get, set or listen to blackboard entries to be notified of changes.

*used in: effectors, components, prereq state, systems, ink game controllers, managers..*

> in prereq state it seems like registering/unregistering is automatically handled by engine

```swift
public class Manager extends IScriptable {
  private let listener: ref<CallbackHandle>;
  
  // register to the changes first
  private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
    let board: ref<IBlackboard> = GameInstance
      .GetBlackboardSystem(playerPuppet.GetGame());

    this.listener = board.RegisterListenerBool(GetAllBlackboardDefs().UIGameData.Popup_IsModal, this, n"OnPopupModalChanged");
  }
  // don't forget to unregister when finished
  private final func PlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {
    let board: ref<IBlackboard> = GameInstance
      .GetBlackboardSystem(playerPuppet.GetGame());

    board.UnregisterListenerBool(GetAllBlackboardDefs().UIGameData.Popup_IsModal, this.listener);
  }

  // changes to the listened blackboard variable will trigger
  protected cb func OnPopupModalChanged(value: Bool) -> Bool {
    // do something..
  }
}
```
