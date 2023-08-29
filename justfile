set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set dotenv-load

# default to steam default game dir
DEFAULT_GAME_DIR    := join("C:\\", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")

mod_name            := 'Addicted'

# installation dir for Cyberpunk 2077, e.g. Steam
repo_dir            := justfile_directory()    
game_dir            := env_var_or_default("GAME_DIR", DEFAULT_GAME_DIR)
bundle_dir          := mod_name

# codebase (outside of game files)
cet_repo_dir        := join(repo_dir, "mods", mod_name)
red_repo_dir        := join(repo_dir, "scripts", mod_name)
tweak_repo_dir      := join(repo_dir, "tweaks", mod_name)
archive_repo_dir    := join(repo_dir, "archive", "packed")
sounds_repo_dir     := join(repo_dir, "archive", "source", "customSounds")
resources_repo_dir  := join(repo_dir, "archive", "source", "raw", "addicted", "resources")

# game files
cet_game_dir        := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", mod_name)
red_game_dir        := join(game_dir, "r6", "scripts", mod_name)
tweak_game_dir      := join(game_dir, "r6", "tweaks", mod_name)
archive_game_dir    := join(game_dir, "archive", "pc", "mod")
redmod_game_dir     := join(game_dir, "mods", mod_name)
red_cache_dir       := join(game_dir, "r6", "cache")

# bundle files for release
cet_bundle_dir      := join(bundle_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", mod_name)
red_bundle_dir      := join(bundle_dir, "r6", "scripts", mod_name)
tweak_bundle_dir    := join(bundle_dir, "r6", "tweaks", mod_name)
archive_bundle_dir  := bundle_dir
redmod_bundle_dir   := join(bundle_dir, "mods", mod_name)

latest_release      := env_var_or_default("LATEST_RELEASE", "")
latest_version      := env_var_or_default("LATEST_VERSION", "")
latest_artifact_windows := mod_name + '-windows-latest-{{latest_version}}.zip'
latest_artifact_linux   := mod_name + "-ubuntu-latest-{{latest_version}}.zip"

# path to REDscript CLI
red_cli             := join(env_var_or_default("RED_CLI", repo_dir), "redscript-cli.exe")

# path to RED cache bundle file in game files
red_cache_bundle    := join(red_cache_dir, "final.redscripts")

# path to WolvenKit CLI
wk_cli              := join(env_var_or_default("WK_CLI", repo_dir), "WolvenKit.CLI.exe")

red4ext_logs        := join(game_dir, "red4ext", "logs", "red4ext.log")
redscript_logs      := join(game_dir, "r6", "logs", "redscript_rCURRENT.log")
cet_logs            := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log")
archivexl_logs      := join(game_dir, "red4ext", "plugins", "ArchiveXL", "ArchiveXL.log")
tweakxl_logs        := join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log")
mod_settings_logs   := join(game_dir, "red4ext", "logs", "mod_settings.log")
mod_logs            := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log")

# list all commands
default:
  @just --list --unsorted
  @echo "⚠️ on Windows, paths defined in .env must be double-escaped:"
  @echo 'e.g. RED_CLI=C:\\\\somewhere\\\\on\\\\my\\\\computer\\\\redscript-cli.exe'

# 📁 run once to create mod folders (if not exist) in game files
setup:
    @if (!(Test-Path '{{cet_game_dir}}'))     { [void](New-Item '{{cet_game_dir}}'     -ItemType Directory); Write-Host "Created folder at {{cet_game_dir}}"; }
    @if (!(Test-Path '{{red_game_dir}}'))     { [void](New-Item '{{red_game_dir}}'     -ItemType Directory); Write-Host "Created folder at {{red_game_dir}}"; }
    @if (!(Test-Path '{{tweak_game_dir}}'))   { [void](New-Item '{{tweak_game_dir}}'   -ItemType Directory); Write-Host "Created folder at {{tweak_game_dir}}"; }
    @if (!(Test-Path '{{redmod_game_dir}}'))  { [void](New-Item '{{redmod_game_dir}}'  -ItemType Directory); Write-Host "Created folder at {{redmod_game_dir}}"; }
    @if (!(Test-Path '{{archive_game_dir}}')) { [void](New-Item '{{archive_game_dir}}' -ItemType Directory); Write-Host "Created folder at {{archive_game_dir}}"; }

# 🎨 lint code
lint:
    '{{red_cli}}' lint -s 'scripts' -b '{{red_cache_bundle}}'

# 🌐 convert translations files with WolvenKit
[windows]
import:
    {{wk_cli}} cr2w -d '{{ join(repo_dir, "archive", "source", "raw", "addicted", "localization") }}' -o '{{ join(repo_dir, "archive", "source", "archive", "addicted", "localization") }}'

# 📦 pack archive with WolvenKit
# deprecated because of bug (biomonitor not triggered, 8.9.0)
# [windows]
# pack: import
#     {{wk_cli}} pack '{{ join(repo_dir, "archive") }}'
#     Move-Item -Force -Path '{{ join(repo_dir, "archive.archive") }}' -Destination '{{ join(repo_dir, "archive", "packed", "archive", "pc", "mod", mod_name + ".archive") }}'
#     Copy-Item -Force '{{ join(repo_dir, "archive", "source", "resources", "Addicted.archive.xl") }}' '{{ join(repo_dir, "archive", "packed", "archive", "pc", "mod", "Addicted.archive.xl") }}'

# 🔛 just compile to check (without building)
compile:
    {{red_cli}} compile -s 'scripts' -b '{{red_cache_bundle}}' -o "dump.redscripts"

# ➡️  copy codebase files to game files, including archive
[windows]
build LOCALE: rebuild
    Copy-Item -Force -Recurse '{{ join(archive_repo_dir, "*") }}' '{{game_dir}}'
    @$folder = '{{ join(redmod_game_dir, "customSounds", LOCALE) }}'; if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    @$folder = '{{ join(redmod_game_dir, "customSounds", "vanilla", LOCALE) }}'; if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    Copy-Item -Force -Recurse '{{ join(repo_dir, "archive", "source", "customSounds", LOCALE, "*") }}' '{{ join(redmod_game_dir, "customSounds", LOCALE) }}'
    Copy-Item -Force -Recurse '{{ join(repo_dir, "archive", "source", "customSounds", "vanilla", LOCALE, "*") }}' '{{ join(redmod_game_dir, "customSounds", "vanilla", LOCALE) }}'
    Copy-Item -Force '{{ join(repo_dir, "archive", "source", "raw", "addicted", "resources", "info." + LOCALE + ".json") }}' '{{ join(redmod_game_dir, "info.json") }}'

deploy:
    cd '{{ join(game_dir, "tools", "redmod", "bin") }}'; .\redMod.exe deploy -root="{{game_dir}}"

# see WolvenKit archive Hot Reload (with Red Hot Tools)
# ↪️  copy codebase files to game files, excluding archive (when game is running)
[windows]
rebuild: setup
    Copy-Item -Force -Recurse '{{ join(cet_repo_dir, "*") }}' '{{cet_game_dir}}'
    Copy-Item -Force -Recurse '{{ join(red_repo_dir, "*") }}' '{{red_game_dir}}'
    Copy-Item -Force -Recurse '{{ join(tweak_repo_dir, "*") }}' '{{tweak_game_dir}}' -Include "*.yml"

# 🧾 show logs from CET and RED
[windows]
logs:
    @if(Test-Path '{{red4ext_logs}}')       { cat '{{red4ext_logs}}' }
    @if(Test-Path '{{redscript_logs}}')     { cat '{{redscript_logs}}' }
    @if(Test-Path '{{cet_logs}}')           { cat '{{cet_logs}}' }
    @if(Test-Path '{{archivexl_logs}}')     { cat '{{archivexl_logs}}' }
    @if(Test-Path '{{tweakxl_logs}}')       { cat '{{tweakxl_logs}}' }
    @if(Test-Path '{{mod_settings_logs}}')  { cat '{{mod_settings_logs}}' }
    @if(Test-Path '{{mod_logs}}')           { cat '{{mod_logs}}' }

# 🧹 clear current cache (r6/cache is not used, only r6/cache/modded matters)
[windows]
clear:
    @if(Test-Path "{{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}" ) { \
        Write-Host "replacing {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }} with {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}"; \
        cp -Force '{{ join(red_cache_dir, "modded", "final.redscripts.bk") }}' '{{ join(red_cache_dir, "modded", "final.redscripts") }}'; \
        Remove-Item -Force -Path '{{ join(red_cache_dir, "modded", "final.redscripts.bk") }}'; \
    } else { \
        Write-Host "missing {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}"; \
    }

# 💾 store (or overwrite) logs in latest.log
[windows]
store:
    (just logs)  | Set-Content 'latest.log'

alias forget := erase

# 🗑️🧾 clear out logs
[windows]
erase: clear
    @$log = '{{ join(game_dir, "red4ext", "logs", "red4ext.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }
    @$log = '{{ join(game_dir, "red4ext", "logs", "mod_settings.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }
    @$log = '{{ join(game_dir, "red4ext", "plugins", "ArchiveXL", "ArchiveXL.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }
    @$log = '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }
    @$log = '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }
    @$log = '{{ join(game_dir, "r6", "logs", "redscript_rCURRENT.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }
    @$log = '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'; \
    if (Test-Path $log) { Remove-Item -Force -Path $log; Write-Host "deleted $log"; } else {  Write-Host "missing $log"; }

# check if given env vars exists
[windows]
check-env NAME:
    @$v = '{{ env_var_or_default(NAME, "") }}'; \
    if ([string]::IsNullOrEmpty($v)) { throw "please set env var: {{NAME}}"; }

# 💠 direct install on Windows from repository (use `just --shell powershell.exe --shell-arg -c install`)
[windows]
install: (check-env 'LATEST_RELEASE') (check-env 'LATEST_VERSION')
    New-Item -ItemType Directory -Force -Path ".installation"
    C:\msys64\usr\bin\wget.exe "https://github.com/cyb3rpsych0s1s/4ddicted/releases/download/{{latest_release}}/{{latest_artifact_windows}}" -P ".installation"
    7z x '${{ join(".installation", latest_artifact_windows) }}' -o ".installation"
    rm -Force "${{latest_artifact_windows}}"
    Get-ChildItem -Path ".installation" | Copy-Item -Destination "${{game_dir}}" -Recurse -Container
    rm -r -Force ".installation"
    start "${{game_dir}}"

# 🐧 direct install on Linux from repository (use `just install`)
[linux]
install: (check-env 'LATEST_RELEASE') (check-env 'LATEST_VERSION')
    mkdir -p ".installation"
    wget "https://github.com/cyb3rpsych0s1s/4ddicted/releases/download/{{latest_release}}/{{latest_artifact_linux}}" -P ".installation"
    7z x '${{ join(".installation", latest_artifact_linux) }}' -o ".installation"
    rm -f '${{ join(".installation", latest_artifact_linux) }}'
    mv ".installation"/. "${{game_dir}}"
    rm -rf ".installation"
    open "${{game_dir}}"

#  Cyberpunk 2077 is not available on MacOS
[macos]
install:
    @echo '🚫 Cyberpunk 2077 is not available on MacOS'

# 📖 read book directly
read:
    mdbook build --open

# 🖊️  book with live hot reload
draft:
    mdbook watch --open

# 📕 assemble book (for release in CI)
assemble:
    mdbook build

# 📦 bundle mod files (for release in CI)
[windows]
bundle:
    @$folder = '{{archive_bundle_dir}}'; \
    if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    @$folder = '{{cet_bundle_dir}}'; \
    if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    @$folder = '{{red_bundle_dir}}'; \
    if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    @$folder = '{{tweak_bundle_dir}}'; \
    if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    Copy-Item -Recurse '{{ join(archive_repo_dir, "*") }}' '{{archive_bundle_dir}}'
    Copy-Item -Recurse '{{ join(cet_repo_dir, "*") }}' '{{cet_bundle_dir}}'
    Copy-Item -Recurse '{{ join(red_repo_dir, "*") }}' '{{red_bundle_dir}}'
    Copy-Item -Recurse '{{ join(tweak_repo_dir, "*") }}' '{{tweak_bundle_dir}}' -Include "*.yml" 
    @just bundle_lang "en-us"

bundle_lang LOCALE:
    @$folder = '{{ join(redmod_bundle_dir, "customSounds", LOCALE) }}'; \
    if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    @$folder = '{{ join(redmod_bundle_dir, "customSounds", "vanilla", LOCALE) }}'; \
    if (!(Test-Path $folder)) { [void](New-Item $folder -ItemType Directory); Write-Host "Created folder at $folder"; }
    Copy-Item -Recurse '{{ join(sounds_repo_dir, LOCALE, "*") }}' '{{ join(redmod_bundle_dir, "customSounds", LOCALE) }}'
    Copy-Item -Recurse '{{ join(sounds_repo_dir, "vanilla", LOCALE, "*") }}' '{{ join(redmod_bundle_dir, "customSounds", "vanilla", LOCALE) }}'
    Copy-Item '{{ join(resources_repo_dir, "info." + LOCALE + ".json") }}' '{{ join(redmod_bundle_dir, "info.json") }}'

# 🗑️🎭⚙️ 🧧🗜️  clear out all mod files in game files
[windows]
uninstall: uninstall-archive uninstall-cet uninstall-red uninstall-tweak uninstall-redmod

# 🗑️🎭  clear out mod archive files in game files
[windows]
uninstall-archive:
    @$file = '{{ join(archive_game_dir, mod_name + ".archive") }}'; \
    if (Test-Path $file -PathType leaf) { Remove-Item -Force -Path $file; Write-Host "deleted $file"; } else {  Write-Host "missing $file"; }
    @$file = '{{ join(archive_game_dir, mod_name + ".archive.xl") }}'; \
    if (Test-Path $file -PathType leaf) { Remove-Item -Force -Path $file; Write-Host "deleted $file"; } else {  Write-Host "missing $file"; }

# 🗑️⚙️   clear out mod CET files in game files
[windows]
uninstall-cet:
    @$folder = '{{cet_game_dir}}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Recurse -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }

# 🗑️🧧  clear out mod REDscript files in game files
[windows]
uninstall-red:
    @$folder = '{{red_game_dir}}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Recurse -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }

# 🗑️🗜️   clear out mod tweaks files in game files
[windows]
uninstall-tweak:
    @$folder = '{{tweak_game_dir}}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Recurse -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }

# 🗑️⚙️   clear out mod REDmod files in game files
[windows]
uninstall-redmod:
    @$folder = '{{redmod_game_dir}}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Recurse -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }

alias nuke := nuclear

# 🧨 nuke your game files as a last resort (vanilla reset)
[windows]
nuclear:
    @$folder = '{{ join(game_dir, "mods") }}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }
    @$folder = '{{ join(game_dir, "plugins") }}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }
    @$folder = '{{ join(game_dir, "r6") }}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }
    @$folder = '{{ join(game_dir, "red4ext") }}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }
    @$folder = '{{ join(game_dir, "archive", "pc", "mod") }}'; \
    if (Test-Path $folder -PathType container) { Remove-Item -Force -Path $folder; Write-Host "deleted $folder"; } else {  Write-Host "missing $folder"; }

# encode .mp3 back into .wav
[windows]
encode OVERWRITE='False':
    @Dir '{{ join(justfile_directory(), "archive", "source", "customSounds") }}' -Recurse -File -Filter "*.mp3" | %{ \
        if ($_.Name -clike "*.mp3") { $from = ".mp3"; $into = ".wav"; } else { $from = ".Mp3"; $into = ".Wav"; } \
        if ((!(Test-Path $_.Fullname.Replace($from,$into) -PathType leaf)) -or ([System.Convert]::ToBoolean('{{OVERWRITE}}'))) { ffmpeg -hide_banner -loglevel error -i $_.Fullname -ar 44100 -sample_fmt s16 -y $_.Fullname.Replace($from,$into); Write-Host "converted " $_.Fullname; } \
    }

# encode .mp3 back into .wav
[macos]
encode OVERWRITE='false':
  for file in `ls ./archive/source/customSounds`; do \
    if [[ ('{{OVERWRITE}}' != 'false' || ! -f ./archive/source/customSounds/${file%.mp3}.wav) && $file == *.mp3 ]]; then \
        ffmpeg -i ./archive/source/customSounds/$file -ar 44100 -sample_fmt s16 -y ./archive/source/customSounds/${file%.mp3}.wav; \
    fi \
  done

# analyze given file audio settings (please install ffprobe manually)
analyze FILE:
  ffprobe -i '{{FILE}}' -show_format -probesize 50000000 -analyzeduration 500
