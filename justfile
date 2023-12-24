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
archive_repo_dir    := join(repo_dir, "archives")

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
    @just recipes/dir '{{cet_game_dir}}';
    @just recipes/dir '{{red_game_dir}}';
    @just recipes/dir '{{tweak_game_dir}}';
    @just recipes/dir '{{redmod_game_dir}}';
    @just recipes/dir '{{archive_game_dir}}';

# 🎨 lint code
lint:
    '{{red_cli}}' lint -s 'scripts' -b '{{red_cache_bundle}}'

# 🌐 convert translations files with WolvenKit
[windows]
import:
    {{wk_cli}} cr2w -d '{{ join(repo_dir, "archive", "source", "raw", "addicted", "localization") }}' -o '{{ join(repo_dir, "archive", "source", "archive", "addicted", "localization") }}'

# 📦 pack archive with WolvenKit
pack:
    {{wk_cli}} pack '{{ join(repo_dir, "archives", "Addicted.Icons", "source", "archive") }}' -o '{{ join(repo_dir, "archives", "Addicted.Icons") }}'
    Move-Item -Path '{{ join(repo_dir, "archives", "Addicted.Icons", "archive.archive") }}' -Destination '{{ join(repo_dir, "archives", "Addicted.Icons.archive") }}' -Force
    {{wk_cli}} pack '{{ join(repo_dir, "archives", "Addicted.VFX", "source", "archive") }}' -o '{{ join(repo_dir, "archives", "Addicted.VFX") }}'
    Move-Item -Path '{{ join(repo_dir, "archives", "Addicted.VFX", "archive.archive") }}' -Destination '{{ join(repo_dir, "archives", "Addicted.VFX.archive") }}' -Force
    {{wk_cli}} pack '{{ join(repo_dir, "archives", "Addicted.Biomon", "source", "archive") }}' -o '{{ join(repo_dir, "archives", "Addicted.Biomon") }}'
    Move-Item -Path '{{ join(repo_dir, "archives", "Addicted.Biomon", "archive.archive") }}' -Destination '{{ join(repo_dir, "archives", "Addicted.Biomon.archive") }}' -Force
    {{wk_cli}} pack '{{ join(repo_dir, "archives", "Addicted.Translations", "source", "archive") }}' -o '{{ join(repo_dir, "archives", "Addicted.Translations") }}'
    Move-Item -Path '{{ join(repo_dir, "archives", "Addicted.Translations", "archive.archive") }}' -Destination '{{ join(repo_dir, "archives", "Addicted.Translations.archive") }}' -Force
    Copy-Item -Path '{{ join(repo_dir, "archives", "Addicted.Translations", "source", "resources", "Addicted.Translations.archive.xl") }}' -Destination '{{ join(repo_dir, "archives", "Addicted.Translations.archive.xl") }}' -Force
    Copy-Item -Force '{{ join(justfile_directory(), "archives", "*.archive") }}' '{{archive_game_dir}}'
    Copy-Item -Force '{{ join(justfile_directory(), "archives", "*.xl") }}' '{{archive_game_dir}}'

# ➡️  copy codebase files to game files, including archive
[windows]
build LOCALE: pack rebuild
    Copy-Item -Force -Recurse '{{ join(repo_dir, "audioware", "*") }}' '{{redmod_game_dir}}'

dev: (build 'en-us')

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
    @just recipes/swap "{{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}" "{{ join(red_cache_dir, 'modded', 'final.redscripts') }}"

# 💾 store (or overwrite) logs in latest.log
[windows]
store:
    (just logs)  | Set-Content 'latest.log'

alias forget := erase

# 🗑️🧾 clear out logs
[windows]
erase: clear
    @just recipes/remove '{{ join(game_dir, "red4ext", "logs", "red4ext.log") }}';
    @just recipes/remove '{{ join(game_dir, "red4ext", "logs", "mod_settings.log") }}';
    @just recipes/remove '{{ join(game_dir, "red4ext", "plugins", "ArchiveXL", "ArchiveXL.log") }}';
    @just recipes/remove '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}';
    @just recipes/remove '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}';
    @just recipes/remove '{{ join(game_dir, "r6", "logs", "redscript_rCURRENT.log") }}';
    @just recipes/remove '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}';

# check if given env vars exists
[windows]
check-env NAME:
    @$v = '{{ env_var_or_default(NAME, "") }}'; \
    if ([string]::IsNullOrEmpty($v)) { throw "please set env var: {{NAME}}"; }

# 📖 read book directly
read:
    cd book; mdbook build --open

# 🖊️  book with live hot reload
draft:
    cd book; mdbook watch --open

# 📕 assemble book (for release in CI)
assemble:
    cd book; mdbook build

# 🗑️🎭⚙️ 🧧🗜️  clear out all mod files in game files
[windows]
uninstall: uninstall-archives uninstall-cet uninstall-red uninstall-tweak uninstall-redmod

# 🗑️🎭  clear out mod archive files in game files
[windows]
uninstall-archives:
    @just recipes/remove '{{ join(archive_game_dir, "Addicted.*.archive") }}';
    @just recipes/remove '{{ join(archive_game_dir, "Addicted.*.archive.xl") }}';

# 🗑️⚙️   clear out mod CET files in game files
[windows]
uninstall-cet:
    @just recipes/trash '{{cet_game_dir}}';

# 🗑️🧧  clear out mod REDscript files in game files
[windows]
uninstall-red:
    @just recipes/trash '{{red_game_dir}}';

# 🗑️🗜️   clear out mod tweaks files in game files
[windows]
uninstall-tweak:
    @just recipes/trash '{{tweak_game_dir}}';

# 🗑️⚙️   clear out mod REDmod files in game files
[windows]
uninstall-redmod:
    @just recipes/trash '{{redmod_game_dir}}';

alias nuke := nuclear

# 🧨 nuke your game files as a last resort (vanilla reset)
[windows]
nuclear:
    @just recipes/trash '{{ join(game_dir, "mods") }}';
    @just recipes/trash '{{ join(game_dir, "plugins") }}';
    @just recipes/trash '{{ join(game_dir, "r6") }}';
    @just recipes/trash '{{ join(game_dir, "red4ext") }}';
    @just recipes/trash '{{ join(game_dir, "archive", "pc", "mod") }}';

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
