# Work in progress

code interesting investigating:

```swift
GameInstance.GetRazerChromaEffectsSystem(scriptInterface.GetGame()).PlayAnimation(n"SlowMotion", true);
```

```swift
private final func PlaySound(SoundEffect: CName) -> Void {
  let audioEvent: ref<SoundPlayEvent> = new SoundPlayEvent();
  audioEvent.soundName = SoundEffect;
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  player.QueueEvent(audioEvent);
}
```

```swift
public abstract importonly class worlduiIGameController extends inkIGameController {
  public final native func ShowGameNotification(data: ref<inkGameNotificationData>) -> ref<inkGameNotificationToken>;
}
```
