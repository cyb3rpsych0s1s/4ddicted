# System

useful to coordinate whole gameplay.

## Persistence

Persistence allow to persist values on game saves.

```swift
enum Case {
  On,
  Off,
}

public class State {
  // do not forget to also set persistence on inner fields
  public persistent let name: CName;
  public persistent let id: TweakDBID;
  public persistent let other: Float;
  // otherwise it won't get persisted
  public let temporary: Bool;
}

public class System extends ScriptableSystem {
  private persistent let count: Int32; // any primitive
  private persistent let case: Case; // including enums
  private persistent let state: ref<State>; // including nested objects
  private persistent let formerStates: array<ref<State>>; // including arrays
  // but
  // no inkHashMap (or similar)
  // no String
  // no Variant
  // no ResRef
}
```

## Requests

Requests are systems' asynchronous mechanism.
It's more often than not used to convey an action.

### Delayed requests

Requests can also be delayed asynchronously.

```swift
public class DoSomethingRequest extends ScriptableSystemRequest {
  public let parameter: Float;
}

public class System extends ScriptableSystem {
  private func DoSomething() -> Void {
    let request: ref<DoSomethingRequest>;
    request.parameter = 1.;
    let delay = 3.; // in seconds, real time
    GameInstance
      .GetDelaySystem(this.GetGameInstance())
      .DelayScriptableSystemRequest(this.GetClassName(), request, delay, true);
      // will automatically call OnDoSomethingRequest on System 3 seconds after
  }

  // function signature matters !
  protected final func OnDoSomethingRequest(request: ref<DoSomethingRequest>) -> Void {
    // do something ..
  }
}
```

### Regular requests

Requests can be queued directly on a system.

```swift
public class DoSomethingRequest extends ScriptableSystemRequest {
  public let parameter: Float;
}

public class System extends ScriptableSystem {
  private func DoSomething() -> Void {
    let request: ref<DoSomethingRequest>;
    request.parameter = 1.;
    this.QueueRequest(request);
    // will automatically call OnDoSomethingRequest on this system
  }

  // function signature matters !
  protected final func OnDoSomethingRequest(request: ref<DoSomethingRequest>) -> Void {
    // do something ..
  }
}
```
