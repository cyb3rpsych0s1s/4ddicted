# wiki

First, a handful of reminders / tips.

## lua VS reds

Cyber Engine Tweaks (CET) and REDscript both offer access to the game API.

- CET uses .lua files.
- REDscript uses .reds files.

```lua
---@param self PlayerPuppet
Observe('PlayerPuppet', 'OnGameAttached', function(self)
  -- execute some logic when player starts game
end)
```

is the equivalent of:

```rust
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    // execute some logic when player starts game
    wrappedMethod();
}
```

## debug

Since:

- any CET method can be called from in-game CET console
- CET can call any REDscript method

This is how to debug own's code, e.g. :

- create a method on PlayerPuppet in .reds
- launch a game session
- open CET console

### quickly call methods

from in-game CET console, e.g.:

```lua
GameObject.PlaySoundEvent(Game.GetPlayer(),"q101_sc_03_heart_loop" )
GameObject.StopSoundEvent(Game.GetPlayer(),"q101_sc_03_heart_loop" )
GameObject.BreakReplicatedEffectLoopEvent(Game.GetPlayer(),"q101_sc_03_heart_loop" )
```

### quickly seed inventory with items

```lua
Game.AddToInventory("Items.FR3SH", 1)
Game.AddToInventory("Items.BonesMcCoy70V0", 3)
Game.AddToInventory("Items.FirstAidWhiffV0", 10)
Game.AddToInventory("Items.BlackLaceV0", 10)
```

### hot reload

Requires latest CET from Discord, at the moment.
Beware of start-up only scripts in your tests: needs to load or start a new game of course.
Red Hot Tools can also watch for changes: beware of autosave.

### REDscript

#### default method return values

credits to `psiberx` on discord.

```swift
public static func NoRetInt() -> Int32 {} // returns 0
public static func NoRetCName() -> CName {} // returns n"None"
public static func NoRetStruct() -> SimpleScreenMessage {} // returns empty instance
public static func NoRetArray() -> array<String> {} // returns empty array
```

#### conditional compilation

REDscripts functions annotated with `@if` conditional compilation macros won't be evaluated.
Quickest way to check if it works is to trigger autocompletion on `this` inside any function.

## native status effects

All the status effects can be found [there](https://cyberpunk.fandom.com/wiki/Cyberpunk_2077_Status_Effects).

## native animations

Animations can be handled with [WolvenKit](https://wiki.redmodding.org/cyberpunk-2077-modding/modding/redmod/quick-guide#animation-modding).

[Change and potentially replace animations](https://wiki.redmodding.org/cyberpunk-2077-modding/developers/guides/quest/how-to-remove-an-animation-and-potentially-replace-it).

## in-game time vs IRL

1 min in-game is 10 real seconds.

credits to `Lyralei` on discord.

## glossary

- `PS` stands for "persistent state".
- `wref` stands for `weak reference` (cc `Rc`). it has nothing to do with (im)mutability.
- `IsDefined` is an intrinsic. It is preferable to testing for nullability directly.
  `IsDefined(wref)` is `wref != null && wref.refCnt > 0`
  `IsDefined(ref)` is `ref != null`
