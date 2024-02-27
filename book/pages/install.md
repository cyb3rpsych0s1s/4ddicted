# Install

Here are the steps required to get yourself started with this mod.

## For players

Mandatory steps, in order:

1. 🎮 Cyberpunk
   > this doc assumes you installed it on Steam
   > but you can easily modify it for whichever game launcher

2. ⚙️ CET
   > scripting engine, based on .lua
   1. download [latest CET release](https://github.com/yamashi/CyberEngineTweaks/releases/latest)
   2. unzip at the root of your game folder
   3. configure in-game
      1. Launch the game and bind the CET menu key (e.g. `Home`)
      2. Quit the game to configure the other mods

You can also watch these steps on video in YouTube, thanks to `PerfectlyNormalBeast`.

[![Installing CET, Redscript, Mod](https://img.youtube.com/vi/klxa3hPTCHk/0.jpg)](https://www.youtube.com/watch?v=klxa3hPTCHk)

Then, in any order:

1. 🧧 REDscript
   > additional supported programming language: `.reds`
   1. download [latest REDscript release](https://github.com/jac3km4/redscript/releases/latest)
   2. unzip at the root of your game folder

2. 🔴 RED4ext
   > relied upon by many mods, allow for extending scripting system
   1. make sure that [Visual C++ Redistributable 2022](https://aka.ms/vs/17/release/vc_redist.x64.exe) is installed
   2. download [latest RED4ext release](https://github.com/WopsS/RED4ext/releases/latest)
   3. unzip at the root of your game folder

3. 🔺 Audioware
   >  used to manage custom souds and subtitles

   **Only** required if you use this mod's [Optional files (audio files and subtitles)](https://www.nexusmods.com/cyberpunk2077/mods/7480?tab=files).
   Kindly note that Audioware itself requires RED4ext (see above).
   1. download [latest Audioware release](https://github.com/cyb3rpsych0s1s/audioware/releases/latest)
   2. unzip at the root of your game folder

4. 🔺 TweakXL
   > useful to create custom tweaks (modify TweakDB, REDengine 4 proprietary database)
   1. download [latest TweakXL release](https://github.com/psiberx/cp2077-tweak-xl/releases/latest)
   2. unzip at the root of your game folder

5. 🔺 ArchiveXL
   > useful to package archive (load custom resources without touching original game files)
   1. download [latest ArchiveXL release](https://github.com/psiberx/cp2077-archive-xl/releases/latest)
   2. unzip at the root of your game folder

6. 🔺 Codeware
   > redscript dependency
   1. download [latest Codeware release](https://github.com/psiberx/cp2077-codeware/releases/latest)
   2. unzip at the root of your game folder

```admonish tip title="Addicted"
And finally this mod itself:

1. download latest Addicted release on [Github](https://github.com/cyb3rpsych0s1s/4ddicted/releases/latest) or [Nexus](https://www.nexusmods.com/cyberpunk2077/mods/7480?tab=files)
2. unzip at the root of your game folder
```

## Only for developers

If you would like to contribute to this repo,
I would strongly recommend:

1. 🔺 Redscript IDE VSCode plugin
   > provides autocompletion in Visual Studio Code
   1. download [latest Redscript IDE VSCode plugin release](https://github.com/jac3km4/redscript-ide-vscode/releases/latest)
   2. install manually in VSCode
2. 🔺 RED Hot Tools
   > allows for archive, scripts and tweaks hot-reloading in-game
   1. download [latest RED Hot Tools release](https://github.com/psiberx/cp2077-red-hot-tools/releases/latest)
   2. unzip at the root of your game folder
3. 🔺 clipTester or SoundClipTester
   > useful to listen to all sounds in-game via CET console
   1. download [from Nexus](https://www.nexusmods.com/cyberpunk2077/mods/1977?tab=files)
   2. unzip at the root of your game folder
