# Troubleshooting

## clean cache

credits to `dddzzzkkk` on Discord:
> basically to fix your issue i think you have to delete the files in the r6\cache\modded folder, delete r6\cache\final.redscripts, rename r6\cache\final.redscripts.bk to r6\cache\final.redscripts, redeploy your REDmods, THEN launch the game

## Press `[None]` to continue

credits to `DJ_Korvrik` : reinstall your Input Loader or delete Cyberpunk 2077\engine\config\platform\pc\input_loader.ini.

## "anchor" variables

one cannot e.g.

```swift
public func GetIDs() -> array<TweakDBID> { ... }

// ❌ WRONG!
public func IsID(id: TweakDBID) -> Bool {
  return ArrayContains(GetIDs(), id);
}
// ✅ do this instead:
public func IsID(id: TweakDBID) -> Bool {
  let ids = GetIDs();
  return ArrayContains(ids, id);
}
```

## handling time conversions

The game already has `GameTime` (the time for V), `GameTimeStamp() -> Float` (the real time), plus `EngineTime` (?) and `SimTime` (?).

There's apparently some issue with the method `TimeSystem.RealTimeSecondsToGameTime()`, unless I wasn't using the right unit of time.
