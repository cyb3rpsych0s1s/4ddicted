# Sounds

Sounds can be played like:

```swift
let sound: CName = n"ono_v_effort_short";
GameObject.PlaySoundEvent(this.player, sound);
GameObject.StopSoundEvent(this.player, sound);
```

Even further controlled with:

```swift
let sound: CName = n"ono_v_effort_short";
let event: ref<PlaySoundEvent> = new PlaySoundEvent();
event.soundEvent = sound;
GameObject.PlaySoundEvent(this.player, sound);
// has ESoundStatusEffects
// also has GetSoundName() / SetSoundName()
event.SetStatusEffect(ESoundStatusEffects.DEAFENED);
// later on
GameObject.StopSoundEvent(this.player, event.soundEvent);
```

Another way:

```swift
let sound: CName = n"dry_fire";
let event: ref<AudioEvent> = new AudioEvent();
event.eventName = sound;
this.player.QueueEvent(event);
```
