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

```reds
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    // execute some logic when player starts game
    wrappedMethod();
}
```

## create state/settings for mod

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

## native status effects

All the status effects can be found [there](https://cyberpunk.fandom.com/wiki/Cyberpunk_2077_Status_Effects).

## native animations

Animations can be handled with [WolvenKit](https://wiki.redmodding.org/cyberpunk-2077-modding/modding/redmod/quick-guide#animation-modding).
[Change and potentially replace animations](https://wiki.redmodding.org/cyberpunk-2077-modding/developers/guides/quest/how-to-remove-an-animation-and-potentially-replace-it).
