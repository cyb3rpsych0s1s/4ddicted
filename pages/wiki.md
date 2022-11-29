# wiki

## lua VS reds

Cyber Engine Tweaks (CET) and REDscript both offer access to the game API.

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

## callbacks

credits: @psiberx - discord — 08/23/2022
there are 3 kinds of events / callbacks

1. based on method name
to handle the event you just have to define function with the right signature and name
it's called by name just like any other function
for example, OnInitialize() in widgets controllers
2. based on event classes inherited from redEvent
to listen for this event you have to define function that has event flag and takes exactly one argument of the type of the event class
it's auto wired during some initialization step (don't remember exact moment)
it can be triggered using methods like QueueEvent()
for example, OnHit(evt : handle:gameeventsHitEvent)
(there's also gameScriptableSystem with gameScriptableSystemRequest working in similar way)
3. callback managers
different types have their own functions to register and unregister listeners
the signature of the listener is always fixed, and you have to know it
you have to define a listener function and register it providing target object and name of the listener method
I think this is the type based on native callbacks, they store `Callback<T>` instances (wrapping target object with the method name) and invoke them
for example, blackboards `RegisterListenerBool(id : gamebbScriptID_Bool, object : handle:IScriptable, func : CName, fireIfValueExist : Bool)`

## workflow

## quickly seed inventory with items

```lua
Game.AddToInventory("Items.FR3SH", 1)
```

### autocompletion

REDscripts functions annotated with `@if` conditional compilation macros won't be evaluated.
Quickest way to check if it works is to trigger autocompletion on `this` inside any function.

### hot reload

Requires latest CET from Discord, at the moment.
Beware of start-up only scripts in your tests: needs to load or start a new game of course.
Red Hot Tools can also watch for changes: beware of autosave.

## create status/settings for mod

```lua
  -- reuse existing entry to create one's status effect
  TweakDB:CloneRecord("BaseStatusEffect.Toxicity", "BaseStatusEffect.Drugged")
  -- ...
  TweakDB:SetFlat("Items.HealingToxicityObjectActionEffect.statusEffect", "BaseStatusEffect.Toxicity")
```

```lua
  -- reuse existing icon to create one's
  TweakDB:CloneRecord("UIIcon.acid_doused", "UIIcon.regeneration_icon")
  TweakDB:SetFlat("UIIcon.acid_doused.atlasPartName", "acid_doused")
```

but actually the truth is that it's far more convenient and maintainable with [YAML Tweaks](https://github.com/psiberx/cp2077-tweak-xl/wiki/YAML-Tweaks).

## native status effects

All the status effects can be found [there](https://cyberpunk.fandom.com/wiki/Cyberpunk_2077_Status_Effects).

## native animations

Animations can be handled with [WolvenKit](https://wiki.redmodding.org/cyberpunk-2077-modding/modding/redmod/quick-guide#animation-modding).
[Change and potentially replace animations](https://wiki.redmodding.org/cyberpunk-2077-modding/developers/guides/quest/how-to-remove-an-animation-and-potentially-replace-it).

## glossary

- `PS` stands for "persistent state".
- `wref` stands for `weak reference` (cc `Rc`). it has nothing to do with (im)mutability.
- `IsDefined` is an intrinsic. It is preferable to testing for nullability directly.
  `IsDefined(wref)` is `wref != null && wref.refCnt > 0`
  `IsDefined(ref)` is `ref != null`
