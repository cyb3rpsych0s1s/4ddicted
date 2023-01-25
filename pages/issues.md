# Issues

## clean cache

from dddzzzkkk on Discord:
> basically to fix your issue i think you have to delete the files in the r6\cache\modded folder, delete r6\cache\final.redscripts, rename r6\cache\final.redscripts.bk to r6\cache\final.redscripts, redeploy your REDmods, THEN launch the game

## "anchor" variables

one cannot e.g.

```swift
public func GetIDs() -> array<TweakDBID> { ... }

// WRONG!
public func IsID(id: TweakDBID) -> Bool {
  return ArrayContains(GetIDs(), id);
}
// do this instead:
public func IsID(id: TweakDBID) -> Bool {
  let ids = GetIDs();
  return ArrayContains(ids, id);
}
```

## handling time conversions

The game already has `GameTime` (the time for V), `GameTimeStamp() -> Float` (the real time), plus `EngineTime` (?) and `SimTime` (?).

There's apparently some issue with the method `TimeSystem.RealTimeSecondsToGameTime()`, unless I wasn't using the right unit of time.

## Press [None] to continue

DJ_Korvrik : reinstall your Input Loader or delete Cyberpunk 2077\engine\config\platform\pc\input_loader.ini

## others

```sh
$ just deploy
'C:Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\tools\redmod\bin\redMod.exe' deploy -root="C:Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077" -mod='nativeSettings','Toxicity','WE3D - Drugs of Night City','MyMod'
No root specified, using default root path.
Invalid root path found: C:\! This might cause errors while running commands.
Copyright (c) 2022 CD Projekt Red. All Rights Reserved.
Created in collaboration with CD Projekt Vancouver and Yigsoft LLC

Continuing without global backend resource depot.
Core: App instance initialized in 0.00 ms


[DEPLOY] Stage 1/5 - Initialization
No mods found, no deployment is needed!


Commandlet deploy has succeeded.
```

//GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_heavy");
//GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);

```sh
[2022-10-30 21:46:55 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:46:55 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:46:55 UTC+07:00] [info] [] {
	name: gamedataStatusEffect_Record,
	functions: {
		MaxStacks() => (whandle:gamedataStatModifierGroup_Record),
		MaxStacksHandle() => (handle:gamedataStatModifierGroup_Record),
		RemoveAllStacksWhenDurationEndsStatModifiers() => (whandle:gamedataStatModifierGroup_Record),
		RemoveAllStacksWhenDurationEndsStatModifiersHandle() => (handle:gamedataStatModifierGroup_Record),
		StatusEffectType() => (whandle:gamedataStatusEffectType_Record),
		StatusEffectTypeHandle() => (handle:gamedataStatusEffectType_Record),
		UiData() => (whandle:gamedataStatusEffectUIData_Record),
		UiDataHandle() => (handle:gamedataStatusEffectUIData_Record),
		Duration() => (whandle:gamedataStatModifierGroup_Record),
		DurationHandle() => (handle:gamedataStatModifierGroup_Record),
		AIData() => (whandle:gamedataStatusEffectAIData_Record),
		AIDataHandle() => (handle:gamedataStatusEffectAIData_Record),
		PlayerData() => (whandle:gamedataStatusEffectPlayerData_Record),
		PlayerDataHandle() => (handle:gamedataStatusEffectPlayerData_Record),
		DebugTags() => (array:CName),
		GetDebugTagsCount() => (Int32),
		GetDebugTagsItem(index: Int32) => (CName),
		DebugTagsContains(item: CName) => (Bool),
		GameplayTags() => (array:CName),
		GetGameplayTagsCount() => (Int32),
		GetGameplayTagsItem(index: Int32) => (CName),
		GameplayTagsContains(item: CName) => (Bool),
		SFX() => (outList: array:whandle:gamedataStatusEffectFX_Record),
		GetSFXCount() => (Int32),
		GetSFXItem(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		GetSFXItemHandle(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		SFXContains(item: whandle:gamedataStatusEffectFX_Record) => (Bool),
		VFX() => (outList: array:whandle:gamedataStatusEffectFX_Record),
		GetVFXCount() => (Int32),
		GetVFXItem(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		GetVFXItemHandle(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		VFXContains(item: whandle:gamedataStatusEffectFX_Record) => (Bool),
		ImmunityStats() => (outList: array:whandle:gamedataStat_Record),
		GetImmunityStatsCount() => (Int32),
		GetImmunityStatsItem(index: Int32) => (whandle:gamedataStat_Record),
		GetImmunityStatsItemHandle(index: Int32) => (whandle:gamedataStat_Record),
		ImmunityStatsContains(item: whandle:gamedataStat_Record) => (Bool),
		Packages() => (outList: array:whandle:gamedataGameplayLogicPackage_Record),
		GetPackagesCount() => (Int32),
		GetPackagesItem(index: Int32) => (whandle:gamedataGameplayLogicPackage_Record),
		GetPackagesItemHandle(index: Int32) => (whandle:gamedataGameplayLogicPackage_Record),
		PackagesContains(item: whandle:gamedataGameplayLogicPackage_Record) => (Bool),
		AdditionalParam() => (CName),
		StopActiveSfxOnDeactivate() => (Bool),
		IsAffectedByTimeDilationPlayer() => (Bool),
		RemoveOnStoryTier() => (Bool),
		Savable() => (Bool),
		RemoveAllStacksWhenDurationEnds() => (Bool),
		IsAffectedByTimeDilationNPC() => (Bool),
		Replicated() => (Bool),
		DynamicDuration() => (Bool),
		GetID() => (TweakDBID),
		ToString() => (String),
		GetClassName() => (CName),
		IsA(className: CName) => (Bool),
		IsExactlyA(className: CName) => (Bool),
	},
	staticFunctions: {
		DetectScriptableCycles(),
	},
	properties: {
	}
}
[2022-10-30 21:46:55 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:46:55 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:46:55 UTC+07:00] [info] [] {
	name: gamedataStatusEffect_Record,
	functions: {
		MaxStacks() => (whandle:gamedataStatModifierGroup_Record),
		MaxStacksHandle() => (handle:gamedataStatModifierGroup_Record),
		RemoveAllStacksWhenDurationEndsStatModifiers() => (whandle:gamedataStatModifierGroup_Record),
		RemoveAllStacksWhenDurationEndsStatModifiersHandle() => (handle:gamedataStatModifierGroup_Record),
		StatusEffectType() => (whandle:gamedataStatusEffectType_Record),
		StatusEffectTypeHandle() => (handle:gamedataStatusEffectType_Record),
		UiData() => (whandle:gamedataStatusEffectUIData_Record),
		UiDataHandle() => (handle:gamedataStatusEffectUIData_Record),
		Duration() => (whandle:gamedataStatModifierGroup_Record),
		DurationHandle() => (handle:gamedataStatModifierGroup_Record),
		AIData() => (whandle:gamedataStatusEffectAIData_Record),
		AIDataHandle() => (handle:gamedataStatusEffectAIData_Record),
		PlayerData() => (whandle:gamedataStatusEffectPlayerData_Record),
		PlayerDataHandle() => (handle:gamedataStatusEffectPlayerData_Record),
		DebugTags() => (array:CName),
		GetDebugTagsCount() => (Int32),
		GetDebugTagsItem(index: Int32) => (CName),
		DebugTagsContains(item: CName) => (Bool),
		GameplayTags() => (array:CName),
		GetGameplayTagsCount() => (Int32),
		GetGameplayTagsItem(index: Int32) => (CName),
		GameplayTagsContains(item: CName) => (Bool),
		SFX() => (outList: array:whandle:gamedataStatusEffectFX_Record),
		GetSFXCount() => (Int32),
		GetSFXItem(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		GetSFXItemHandle(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		SFXContains(item: whandle:gamedataStatusEffectFX_Record) => (Bool),
		VFX() => (outList: array:whandle:gamedataStatusEffectFX_Record),
		GetVFXCount() => (Int32),
		GetVFXItem(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		GetVFXItemHandle(index: Int32) => (whandle:gamedataStatusEffectFX_Record),
		VFXContains(item: whandle:gamedataStatusEffectFX_Record) => (Bool),
		ImmunityStats() => (outList: array:whandle:gamedataStat_Record),
		GetImmunityStatsCount() => (Int32),
		GetImmunityStatsItem(index: Int32) => (whandle:gamedataStat_Record),
		GetImmunityStatsItemHandle(index: Int32) => (whandle:gamedataStat_Record),
		ImmunityStatsContains(item: whandle:gamedataStat_Record) => (Bool),
		Packages() => (outList: array:whandle:gamedataGameplayLogicPackage_Record),
		GetPackagesCount() => (Int32),
		GetPackagesItem(index: Int32) => (whandle:gamedataGameplayLogicPackage_Record),
		GetPackagesItemHandle(index: Int32) => (whandle:gamedataGameplayLogicPackage_Record),
		PackagesContains(item: whandle:gamedataGameplayLogicPackage_Record) => (Bool),
		AdditionalParam() => (CName),
		StopActiveSfxOnDeactivate() => (Bool),
		IsAffectedByTimeDilationPlayer() => (Bool),
		RemoveOnStoryTier() => (Bool),
		Savable() => (Bool),
		RemoveAllStacksWhenDurationEnds() => (Bool),
		IsAffectedByTimeDilationNPC() => (Bool),
		Replicated() => (Bool),
		DynamicDuration() => (Bool),
		GetID() => (TweakDBID),
		ToString() => (String),
		GetClassName() => (CName),
		IsA(className: CName) => (Bool),
		IsExactlyA(className: CName) => (Bool),
	},
	staticFunctions: {
		DetectScriptableCycles(),
	},
	properties: {
	}
}
```

```sh
[2022-10-30 21:53:00 UTC+07:00] [info] [] Cyber Engine Tweaks startup complete.
[2022-10-30 21:53:00 UTC+07:00] [info] [] Mod Addicted loaded! ('C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\Addicted')
[2022-10-30 21:53:00 UTC+07:00] [info] [] Mod nativeSettings loaded! ('C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\nativeSettings')
[2022-10-30 21:53:00 UTC+07:00] [info] [] Mod RedHotTools loaded! ('C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\RedHotTools')
[2022-10-30 21:53:00 UTC+07:00] [info] [] Mod Toxicity loaded! ('C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\Toxicity')
[2022-10-30 21:53:00 UTC+07:00] [info] [] Mod WE3D - Drugs of Night City loaded! ('C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\WE3D - Drugs of Night City')
[2022-10-30 21:53:31 UTC+07:00] [info] [] RED:Addicted:OnGameAttached
[2022-10-30 21:53:31 UTC+07:00] [info] [] CET:Addicted:onInit
[2022-10-30 21:53:31 UTC+07:00] [info] [] WE3D Language file loaded
[2022-10-30 21:53:31 UTC+07:00] [info] [] WE3D integrated with Native Settings UI
[2022-10-30 21:53:31 UTC+07:00] [info] [] WE3D Language file 2 loaded
[2022-10-30 21:53:32 UTC+07:00] [info] [] WE3D main loaded
[2022-10-30 21:53:32 UTC+07:00] [info] [] WE3D functions loaded
[2022-10-30 21:53:32 UTC+07:00] [info] [] WE3D fully loaded!
[2022-10-30 21:53:32 UTC+07:00] [info] [] [NativeSettings] NativeSettings lib initialized!
[2022-10-30 21:53:32 UTC+07:00] [info] [] LuaVM: initialization finished!
[2022-10-30 21:53:54 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:53:54 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:53:54 UTC+07:00] [info] [] The status effect is <TDBID:EAB61494:1D>
[2022-10-30 21:54:04 UTC+07:00] [info] [] RED:Addicted:OnGameAttached
[2022-10-30 21:54:04 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:04 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:04 UTC+07:00] [info] [] The status effect is <TDBID:73A1CB09:29>
[2022-10-30 21:54:04 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:04 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:04 UTC+07:00] [info] [] The status effect is <TDBID:643FF81E:23>
[2022-10-30 21:54:04 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:04 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:04 UTC+07:00] [info] [] The status effect is <TDBID:31CE848E:23>
[2022-10-30 21:54:17 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] The status effect is <TDBID:235ECDC4:26>
[2022-10-30 21:54:17 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] The status effect is <TDBID:235ECDC4:26>
[2022-10-30 21:54:17 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] The status effect is <TDBID:EAB61494:1D>
[2022-10-30 21:54:17 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] The status effect is <TDBID:EAB61494:1D>
[2022-10-30 21:54:17 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] RED:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] The status effect is <TDBID:EAB61494:1D>
[2022-10-30 21:54:17 UTC+07:00] [info] [] CET:Addicted:OnStatusEffectApplied
[2022-10-30 21:54:17 UTC+07:00] [info] [] RED:
```

You don't see BaseStatusEffect.FirstAidWhiffV{0/1/2}?

---

shenanigans with game systems:

```sh
\n=== Toxicity ===\n
[2022-11-04 18:18:31 UTC+07:00] [error] [] ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:310: attempt to index local 'player' (a nil value)    
stack traceback:
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:310: in function 'refreshCurrentState'
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:993: in function 'initialize'
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:1002: in function 'Observe'
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:1035: in function 'Listen'
        ...n\x64\plugins\cyber_engine_tweaks\mods\Toxicity\init.lua:163: in function 'SetupLanguageListener'
        ...n\x64\plugins\cyber_engine_tweaks\mods\Toxicity\init.lua:16: in function <...n\x64\plugins\cyber_engine_tweaks\mods\Toxicity\init.lua:13>
[2022-11-04 18:22:51 UTC+07:00] [error] [] ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:310: attempt to index local 'player' (a nil value)    
stack traceback:
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:310: in function 'refreshCurrentState'
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:993: in function 'initialize'
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:1002: in function 'Observe'
        ...x64\plugins\cyber_engine_tweaks\mods\Toxicity\GameUI.lua:1035: in function 'Listen'
        ...n\x64\plugins\cyber_engine_tweaks\mods\Toxicity\init.lua:163: in function 'SetupLanguageListener'
        ...n\x64\plugins\cyber_engine_tweaks\mods\Toxicity\init.lua:16: in function <...n\x64\plugins\cyber_engine_tweaks\mods\Toxicity\init.lua:13>

```lua
if player == nil then return end -- hotfix
```
