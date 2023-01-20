# Patterns

## System

useful to coordinate whole gameplay.

### Persistence

Persistence allow to persist values on game saves.

```swift
public enum Case {
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

### Requests

Requests are an asynchronous mechanism.
It's more often than not used to convey an action.
> *something is **requested***

#### Delayed requests

Requests can be delayed asynchronously.

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

#### Regular requests

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

## Callbacks

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

## Events

Events are another asynchronous mechanism.
It's more often than not used to notify other parts of the code.
> *something is **happening***

### Tickable events

Tickable events are events whose progression can be tracked.
Only work on `Entity`, so usually `PlayerPuppet`.
The benefit of `TickableEvent` is that you get its state and progress available.

> During my own experiments, I wasn't able to call it on a custom class which extends Entity.

```swift
// define your event
public class ProgressionEvent extends TickableEvent {}

public class System extends ScriptableSystem {
  private let player: wref<PlayerPuppet>;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      E(s"initialize system on player attach");
      this.player = player;
      let evt: ref<ProgressionEvent> = new ProgressionEvent();
      // tick repeatedly for 3 seconds
      GameInstance.GetDelaySystem(this.player.GetGame()).TickOnEvent(this.player, evt, 3.);

      this.RefreshConfig();
    } else { F(s"no player found!"); }
  }
}

// this method will get called repeatedly on each tick
// for the duration of the event or until canceled.
// signature of the function matters !
@addMethod(PlayerPuppet)
protected cb func OnProgressionEvent(evt: ref<ProgressionEvent>) -> Bool {
  // do something ..
}
```

### Delayed events

Regular events can be delayed asynchronously too.

> credits to Lyralei on Discord.

```swift
@addField(PlayerPuppet)
public let m_EventDelayID: ref<DelayID>; // Id the game creates for us. This is necessary for eventually cancelling your event if you ever have to.

public class YourEventClassName extends Event 
{
// Can be empty, but if you need it to save any data to use later in your "handling" function, make sure to add the necessary variables here.
  public let player: ref<PlayerPuppet>;
}

// Setup Event. Has to be in the class that is the owner.
@addMethod(PlayerPuppet)
public final func SetupEvent(delay: Float) -> Void {
  let evt: ref<YourEventClassName > = new YourEventClassName();

  // Example on how to set your variable data 
  evt.player = this;
  this.m_EventDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, delay, false);
}

// As soon as V is entered the world, we want to start the event.
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  if !this.IsReplacer() {
    this.SetupEvent(5.00); // 5.00 == 5 real life seconds. 1 min in-game is 10 real seconds.
  }
}

// Has to be added to the main class that is the owner. Format of the function is important! This is how we call our handling function:
@addMethod(PlayerPuppet)
protected cb func OnHandlingEvent(evt: ref<YourEventClassName >) -> Void {
  LogChannel(n"DEBUG", "Running Event now!");
}
```

### Regular events

> credits to Lyralei on Discord.

Here `QueueEvent` generally means *it's gonna be played as soon as possible*.

```swift
public class YourEventClassName extends Event 
{
// Can be empty, but if you need it to save any data to use later in your "handling" function, make sure to add the necessary variables here.
  public let player: ref<PlayerPuppet>;
}

// Setup Event. Has to be in the class that is the owner.
@addMethod(PlayerPuppet)
public final func DoEvent() -> Void {
  let evt: ref<YourEventClassName > = new YourEventClassName();
  this.QueueEvent(evt);
}

// As soon as V is entered the world, we want to start the event.
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  if !this.IsReplacer() {
    this.DoEvent();
  }
}
```

## Blackboards

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

## Stats listeners

Detoxifier (a.k.a `ToxinCleanser`) grants:

`gamedataStatType.PoisonImmunity`
`gamedataStatType.HasPoisonImmunity`

example from the sources for `gamedataStatType.AutoReveal`:

```swift
public class AutoRevealStatListener extends ScriptStatsListener {
  public let m_owner: wref<GameObject>;
  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    let updateRequest: ref<UpdateAutoRevealStatEvent>;
    if Equals(statType, gamedataStatType.AutoReveal) && IsDefined(this.m_owner as PlayerPuppet) {
      updateRequest = new UpdateAutoRevealStatEvent();
      updateRequest.hasAutoReveal = total > 0.00;
      this.m_owner.QueueEvent(updateRequest);
    };
  }
}

public class UpdateAutoRevealStatEvent extends Event {
  public let hasAutoReveal: Bool;
}

public class PlayerPuppet extends ScriptedPuppet {
  protected cb func OnUpdateAutoRevealStatEvent(evt: ref<UpdateAutoRevealStatEvent>) -> Bool {
    // do something ...
  }
  protected final func RegisterStatListeners(self: ref<PlayerPuppet>) -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: EntityID = this.GetEntityID();
    this.m_autoRevealListener = new AutoRevealStatListener();
    this.m_autoRevealListener.SetStatType(gamedataStatType.AutoReveal);
    this.m_autoRevealListener.m_owner = self;
    statsSystem.RegisterListener(Cast<StatsObjectID>(entityID), this.m_autoRevealListener);
  }
  protected final func UnregisterStatListeners(self: ref<PlayerPuppet>) -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: EntityID = this.GetEntityID();
    statsSystem.UnregisterListener(Cast<StatsObjectID>(entityID), this.m_autoRevealListener);
    this.m_autoRevealListener = null;
  }
}
```

- `ScriptStatsListener`     :arrow_right: `BaseStats`
- `ScriptStatPoolsListener` :arrow_right: `BaseStatPools`
- ...

## Effectors

Or simply put, adding custom logic at runtime to statically defined status effects.

Looking at `BaseStatusEffect.BerserkPlayer` in its 2nd `packages`,
then down in its `effectors` first entry,
there's `BaseStatusEffect.BerserkPlayerSFXEffector` which `effectorClassName` is `PlaySFXEffector`.

If searching in game sources, there's indeed a `PlaySFXEffector` (which extends `Effector`/`IScriptable`),
which seems to allow for tweaking e.g. the effect at runtime based on conditions:

```swift
public class PlaySFXEffector extends Effector {
  // ...
  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if !this.m_startOnUninitialize && IsNameValid(this.activationSFXName) {
      if !this.m_unique {
        GameObject.PlaySound(this.m_owner, this.activationSFXName, n"PlaySFXEffector");
      } else {
        GameObject.PlaySoundWithParams(this.m_owner, this.activationSFXName, n"PlaySFXEffector", audioAudioEventFlags.Unique);
      };
    };
  }
}
```

## Lifecycle

Certain methods are always called by the engine and can be leveraged to make sure that code is executed at the right time and/or for cleanup.

### On creation / destruction

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
