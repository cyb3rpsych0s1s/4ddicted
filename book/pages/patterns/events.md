# Events

Events are another asynchronous mechanism.
It's more often than not used to notify other parts of the code.

## Tickable events

Tickable events are events whose progression can be tracked.
Only work on `Entity`, so usually `PlayerPuppet`.
The benefit of `TickableEvent` is that you get its state and progress available.

> During my own experiments, I wasn't able to call it on a custom class which extends `Entity`.

```swift
// define your event
public class ProgressionEvent extends TickableEvent {}

public class System extends ScriptableSystem {
  private let player: wref<PlayerPuppet>;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if IsDefined(player) {
      LogChannel(n"DEBUG", s"initialize system on player attach");
      this.player = player;
      let evt: ref<ProgressionEvent> = new ProgressionEvent();
      // tick repeatedly for 3 seconds
      GameInstance.GetDelaySystem(this.player.GetGame()).TickOnEvent(this.player, evt, 3.);

    } else { LogError(s"no player found!"); }
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

## Delayed events

Regular events can be delayed asynchronously too.

> credits to `Lyralei` on Discord.

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

## Regular events

> credits to `Lyralei` on Discord.

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

### event inherited from RED Event

see [cyberdoc](https://jac3km4.github.io/cyberdoc/#11485)

```swift
public native class GameObject extends GameEntity {
  // certain event will automatically trigger a method with this exact signature
  //                               vvvvvvvvvvvv
  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    this.SetScannerDirty(true);
    this.ProcessDamagePipeline(evt);
  }
}
```

> credits to psiberx
