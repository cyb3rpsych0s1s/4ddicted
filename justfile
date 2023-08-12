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
resources_repo_dir  := join(repo_dir, "archive", "source", "resources")

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
archive_bundle_dir  := join(bundle_dir, "archive", "pc", "mod")
redmod_bundle_dir   := join(bundle_dir, "mods", mod_name)

latest_release      := env_var_or_default("LATEST_RELEASE", "")
latest_version      := env_var_or_default("LATEST_VERSION", "")
latest_artifact_windows := mod_name + '-windows-latest-{{latest_version}}.zip'
latest_artifact_linux   := mod_name + "-ubuntu-latest-{{latest_version}}.zip"

# path to REDscript CLI
red_cli             := env_var_or_default("RED_CLI", repo_dir)

# path to RED cache bundle file in game files
red_cache_bundle    := join(red_cache_dir, "final.redscripts")

# path to WolvenKit CLI
wk_cli              := env_var_or_default("WK_CLI", repo_dir)

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
    @if (!(Test-Path '{{cet_game_dir}}')) { New-Item '{{cet_game_dir}}' -ItemType Directory; Write-Host "Created folder at {{cet_game_dir}}"; }
    @if (!(Test-Path '{{red_game_dir}}')) { New-Item '{{red_game_dir}}' -ItemType Directory; Write-Host "Created folder at {{red_game_dir}}"; }
    @if (!(Test-Path '{{tweak_game_dir}}')) { New-Item '{{tweak_game_dir}}' -ItemType Directory; Write-Host "Created folder at {{tweak_game_dir}}"; }
    @if (!(Test-Path '{{redmod_game_dir}}')) { New-Item '{{redmod_game_dir}}' -ItemType Directory; Write-Host "Created folder at {{redmod_game_dir}}"; }
    @if (!(Test-Path '{{archive_game_dir}}')) { New-Item '{{archive_game_dir}}' -ItemType Directory; Write-Host "Created folder at {{archive_game_dir}}"; }

# 🎨 lint code
lint:
    '{{red_cli}}' lint -s 'scripts' -b '{{red_cache_bundle}}'

# 🌐 convert translations files with WolvenKit
[windows]
import:
    {{wk_cli}} cr2w -d '{{ join(repo_dir, "archive", "source", "raw", "addicted", "localization") }}' -o '{{ join(repo_dir, "archive", "source", "archive", "addicted", "localization") }}'

# 📦 pack archive with WolvenKit
[windows]
pack LANGUAGE='en-us': import
    {{wk_cli}} pack '{{ join(repo_dir, "archive") }}'
    Move-Item -Force -Path '{{ join(repo_dir, "archive.archive") }}' -Destination '{{ join(repo_dir, "archive", "packed", "archive", "pc", "mod", mod_name + ".archive") }}'
    cp -Force '{{ join(repo_dir, "archive", "source", "resources", "Addicted.archive.xl") }}' '{{ join(repo_dir, "archive", "packed", "archive", "pc", "mod", "Addicted.archive.xl") }}'

# 🔛 just compile to check (without building)
compile:
    '{{red_cli}}' compile -s 'scripts' -b '{{red_cache_bundle}}' -o "dump.redscripts"

# ➡️  copy codebase files to game files, including archive
[windows]
build LANGUAGE='en-us': rebuild
    cp -Recurse -Force '{{ join(archive_repo_dir, "*") }}' '{{game_dir}}'
    @if (!(Test-Path '{{ join(redmod_game_dir, "customSounds") }}')) { New-Item '{{ join(redmod_game_dir, "customSounds") }}' -ItemType Directory; Write-Host "Created folder at {{ join(redmod_game_dir, 'customSounds') }}"; }
    @if (!(Test-Path '{{ join(redmod_game_dir, "customSounds", "vanilla") }}')) { New-Item '{{ join(redmod_game_dir, "customSounds", "vanilla") }}' -ItemType Directory; Write-Host "Created folder at {{ join(redmod_game_dir, 'customSounds', 'vanilla') }}"; }
    cp -Recurse -Force '{{ join(repo_dir, "archive", "source", "customSounds", LANGUAGE) }}' '{{ join(redmod_game_dir, "customSounds") }}'
    cp -Recurse -Force '{{ join(repo_dir, "archive", "source", "customSounds", "vanilla", LANGUAGE) }}' '{{ join(redmod_game_dir, "customSounds", "vanilla") }}'
    cp -Force '{{ join(repo_dir, "archive", "source", "raw", "addicted", "resources", "info." + LANGUAGE + ".json") }}' '{{ join(redmod_game_dir, "customSounds", "info.json") }}'

deploy:
    cd '{{ join(game_dir, "tools", "redmod", "bin") }}' && \
    ./redMod.exe deploy -root="{{game_dir}}"

# see WolvenKit archive Hot Reload (with Red Hot Tools)
# ↪️  copy codebase files to game files, excluding archive (when game is running)
[windows]
rebuild:
    cp -Recurse -Force '{{ join(cet_repo_dir, "*") }}' '{{cet_game_dir}}'
    cp -Recurse -Force '{{ join(red_repo_dir, "*") }}' '{{red_game_dir}}'
    cp -Recurse -Force '{{ join(tweak_repo_dir, "*") }}' '{{tweak_game_dir}}'

# 🧾 show logs from CET and RED
logs:
    @[ -f '{{red4ext_logs}}' ]       && cat '{{red4ext_logs}}'
    @[ -f '{{redscript_logs}}' ]     && cat '{{redscript_logs}}'
    @[ -f '{{cet_logs}}' ]           && cat '{{cet_logs}}'
    @[ -f '{{archivexl_logs}}' ]     && cat '{{archivexl_logs}}'
    @[ -f '{{tweakxl_logs}}' ]       && cat '{{tweakxl_logs}}'
    @[ -f '{{mod_settings_logs}}' ]  && cat '{{mod_settings_logs}}'
    @[ -f '{{mod_logs}}' ]           && cat '{{mod_logs}}'

# 🧹 clear current cache (r6/cache is not used, only r6/cache/modded matters)
clear:
    @if [[ -f "{{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}" ]]; then \
        echo "replacing {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }} with {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}"; \
        cp -f '{{ join(red_cache_dir, "modded", "final.redscripts.bk") }}' '{{ join(red_cache_dir, "modded", "final.redscripts") }}'; \
        rm -f '{{ join(red_cache_dir, "modded", "final.redscripts.bk") }}'; \
    else \
        echo "missing {{ join(red_cache_dir, 'modded', 'final.redscripts.bk') }}"; \
    fi

# 💾 store (or overwrite) logs in latest.log
store:
    (just logs)  > 'latest.log'

alias forget := erase

# 🗑️🧾 clear out logs
erase: clear
    rm -f '{{ join(game_dir, "red4ext", "logs", "red4ext.log") }}' \
    '{{ join(game_dir, "red4ext", "logs", "mod_settings.log") }}' \
    '{{ join(game_dir, "red4ext", "plugins", "ArchiveXL", "ArchiveXL.log") }}' \
    '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' \
    '{{ join(game_dir, "r6", "logs", "redscript_rCURRENT.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'

# check if given env vars exists
check-env NAME:
    [[ "{{ env_var_or_default(NAME, '') }}" != "" ]] || {{ error('please set env var: ' + NAME) }};

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
bundle:
    mkdir -p '{{archive_repo_dir}}'
    mv archive.archive '{{ join(archive_repo_dir, "Addicted.archive") }}'
    cp '{{ join("archive", "source", "resources", "Addicted.archive.xl") }}' '{{ join(archive_repo_dir, "Addicted.archive.xl") }}'

    mkdir -p '{{archive_bundle_dir}}'
    mkdir -p '{{cet_bundle_dir}}'
    mkdir -p '{{red_bundle_dir}}'
    mkdir -p '{{tweak_bundle_dir}}'
    mkdir -p '{{ join(redmod_bundle_dir, "customSounds") }}'
    cp -r '{{archive_repo_dir}}'/. '{{archive_bundle_dir}}'
    cp -r '{{cet_repo_dir}}'/. '{{cet_bundle_dir}}'
    cp -r '{{red_repo_dir}}'/. '{{red_bundle_dir}}'
    cp -r '{{tweak_repo_dir}}'/. '{{tweak_bundle_dir}}'
    @just bundle_lang

bundle_lang CODE='en-us' FILE='info.json':
    mkdir -p '{{ join(redmod_bundle_dir, "customSounds") }}'
    @just copy_recursive '{{sounds_repo_dir}}' {{CODE}} wav '{{ join(`pwd`, redmod_bundle_dir, "customSounds") }}' 'true'
    @just copy_recursive '{{sounds_repo_dir}}' vanilla/{{CODE}} Wav '{{ join(`pwd`, redmod_bundle_dir, "customSounds") }}' 'false'
    cp '{{ join(resources_repo_dir, FILE) }}' '{{ join(redmod_bundle_dir, "info.json") }}'

[private]
[windows]
copy_recursive IN SUB EXT OUT NESTED='false':
    cd '{{IN}}' && cp -r --parents {{SUB}}/**/*.{{EXT}} '{{OUT}}'

[private]
[linux]
copy_recursive IN SUB EXT OUT NESTED='false':
    rsync -R {{ join(IN, SUB, if NESTED == "false" { "" } else { "**" }, "*." + EXT) }} {{OUT}}

[private]
[macos]
copy_recursive IN SUB EXT OUT NESTED='false':
    cd '{{IN}}' && rsync -Rr {{ join(SUB, if NESTED == "false" { "" } else { "**" }, "*." + EXT) }} {{OUT}}

# 🗑️🎭⚙️ 🧧🗜️  clear out all mod files in game files
uninstall: uninstall-archive uninstall-cet uninstall-red uninstall-tweak uninstall-redmod

# 🗑️🎭  clear out mod archive files in game files
uninstall-archive:
    rm -f '{{archive_game_dir}}'/Addicted.archive
    rm -f '{{archive_game_dir}}'/Addicted.archive.xl

# 🗑️⚙️   clear out mod CET files in game files
uninstall-cet:
    rm -rf '{{cet_game_dir}}'

# 🗑️🧧  clear out mod REDscript files in game files
uninstall-red:
    rm -rf '{{red_game_dir}}'

# 🗑️🗜️   clear out mod tweaks files in game files
uninstall-tweak:
    rm -rf '{{tweak_game_dir}}'

# 🗑️⚙️   clear out mod REDmod files in game files
uninstall-redmod:
    rm -rf '{{redmod_game_dir}}'

alias nuke := nuclear

# 🧨 nuke your game files as a last resort (vanilla reset)
nuclear:
    rm -rf '{{ join(game_dir, "mods") }}'
    rm -rf '{{ join(game_dir, "plugins") }}'
    rm -rf '{{ join(game_dir, "engine") }}'
    rm -rf '{{ join(game_dir, "r6") }}'
    rm -rf '{{ join(game_dir, "red4ext") }}'
    rm -rf '{{ join(game_dir, "archive", "pc", "mod") }}'

# ↘️  extract audios (add .wem to WolvenKit project, then point to this directory and specify where to export)
extract IN OUT:
    mkdir -p '{{OUT}}'
    '{{wk_cli}}' export '{{IN}}' -o '{{OUT}}'

# encode .mp3 back into .wav
encode OVERWRITE='false':
  for file in `ls ./archive/source/customSounds`; do \
    if [[ ('{{OVERWRITE}}' != 'false' || ! -f ./archive/source/customSounds/${file%.mp3}.wav) && $file == *.mp3 ]]; then \
        ffmpeg -i ./archive/source/customSounds/$file -ar 44100 -sample_fmt s16 -y ./archive/source/customSounds/${file%.mp3}.wav; \
    fi \
  done

# analyze given file audio settings (please install ffprobe manually)
analyze FILE:
  ffprobe -i '{{FILE}}' -show_format -probesize 50000000 -analyzeduration 500
