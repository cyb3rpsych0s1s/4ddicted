set dotenv-load

# default to steam default game dir
DEFAULT_GAME_DIR := join("C:\\", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")
# default to CI RED cli path
DEFAULT_RED_CLI := join(".", "redscript-cli.exe")
# default to local WolvenKit cli path
DEFAULT_WK_CLI := join(".", "WolvenKit.CLI.exe")

# installation dir for Cyberpunk 2077, e.g. Steam
game_dir := env_var_or_default("GAME_DIR", DEFAULT_GAME_DIR)
bundle_dir := 'Addicted'
alt_game_dir := '../../../Program Files (x86)/Steam/steamapps/common/Cyberpunk 2077'

# codebase (outside of game files)
cet_input_dir := join("mods", "Addicted")
red_input_dir := join("scripts", "Addicted")
tweak_input_dir := join("tweaks", "Addicted")
archive_input_dir := join("archive", "packed")

# game files
cet_output_dir := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted")
red_output_dir := join(game_dir, "r6", "scripts", "Addicted")
tweak_output_dir := join(game_dir, "r6", "tweaks", "Addicted")
archive_output_dir := join(game_dir, "archive", "pc", "mod")
red_cache_dir := join(game_dir, "r6", "cache")

# bundle files for release
cet_release_dir := join(bundle_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted")
red_release_dir := join(bundle_dir, "r6", "scripts", "Addicted")
tweak_release_dir := join(bundle_dir, "r6", "tweaks", "Addicted")
archive_release_dir := join(bundle_dir, "archive", "pc", "mod")

latest_release := env_var_or_default("LATEST_RELEASE", "")
latest_version := env_var_or_default("LATEST_VERSION", "")
latest_artifact_windows := 'Addicted-windows-latest-{{latest_version}}.zip'
latest_artifact_linux := "Addicted-ubuntu-latest-{{latest_version}}.zip"

# path to REDscript CLI
red_cli := env_var_or_default("RED_CLI", DEFAULT_RED_CLI)

# path to RED cache bundle file in game files
red_cache_bundle := join(red_cache_dir, "final.redscripts")

# path to WolvenKit CLI
wk_cli := env_var_or_default("WK_CLI", DEFAULT_WK_CLI)

# list all commands
default:
  @just --list --unsorted
  @echo "⚠️ on Windows, paths defined in .env must be double-escaped:"
  @echo 'e.g. RED_CLI=C:\\\\somewhere\\\\on\\\\my\\\\computer\\\\redscript-cli.exe'

# 📁 run once to create mod folders (if not exist) in game files
setup:
    mkdir -p '{{cet_output_dir}}'
    mkdir -p '{{red_output_dir}}'

# 🎨 lint code
lint:
    '{{red_cli}}' lint -s 'scripts' -b '{{red_cache_bundle}}'

# 🔛 just compile to check (without building)
compile:
    '{{red_cli}}' compile -s 'scripts' -b '{{red_cache_bundle}}' -o "dump.redscripts"

# ➡️  copy codebase files to game files, including archive
build: rebuild
    cp -r '{{archive_input_dir}}'/. '{{game_dir}}'

deploy: build
    cd '{{ join(game_dir, "tools", "redmod", "bin") }}' && \
    ./redMod.exe deploy -root="{{game_dir}}"

# see WolvenKit archive Hot Reload (with Red Hot Tools)
# ↪️  copy codebase files to game files, excluding archive (when game is running)
rebuild:
    cp -r '{{cet_input_dir}}'/. '{{cet_output_dir}}'
    cp -r '{{red_input_dir}}'/. '{{red_output_dir}}'
    cp -r '{{tweak_input_dir}}'/. '{{tweak_output_dir}}'
    @just wolvenkit_hotfix

# WolvenKit hotfix : copy custom sounds related files to packed folder
wolvenkit_hotfix:
    cp -R './archive/source/customSounds' '{{ join(archive_input_dir, "mods", "Addicted", "customSounds") }}'
    cp './archive/source/info.json' '{{ join(archive_input_dir, "mods", "Addicted", "info.json") }}'

# 🧾 show logs from CET and RED
logs:
    echo "\n=== TweakXL ===\n" && \
    cat '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}' && \
    echo "\n=== CET ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' && \
    echo "\n=== REDscript ===\n" && \
    cat '{{ join(game_dir, "r6", "logs", "redscript_rCURRENT.log") }}' && \
    echo "\n=== Toxicity ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'

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
    rm -f '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}' \
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
    mkdir -p '{{archive_input_dir}}'
    mv archive.archive '{{ join(archive_input_dir, "Addicted.archive") }}'
    cp '{{ join("archive", "source", "resources", "Addicted.archive.xl") }}' '{{ join(archive_input_dir, "Addicted.archive.xl") }}'

    mkdir -p '{{archive_release_dir}}'
    mkdir -p '{{cet_release_dir}}'
    mkdir -p '{{red_release_dir}}'
    mkdir -p '{{tweak_release_dir}}'
    cp -r '{{archive_input_dir}}'/. '{{archive_release_dir}}'
    cp -r '{{cet_input_dir}}'/. '{{cet_release_dir}}'
    cp -r '{{red_input_dir}}'/. '{{red_release_dir}}'
    cp -r '{{tweak_input_dir}}'/. '{{tweak_release_dir}}'

# 🗑️🎭⚙️ 🧧🗜️  clear out all mod files in game files
uninstall: uninstall-archive uninstall-cet uninstall-red uninstall-tweak

# 🗑️🎭  clear out mod archive files in game files
uninstall-archive:
    rm -f '{{archive_output_dir}}'/Addicted.archive
    rm -f '{{archive_output_dir}}'/Addicted.archive.xl

# 🗑️⚙️   clear out mod CET files in game files
uninstall-cet:
    rm -rf '{{cet_output_dir}}'

# 🗑️🧧  clear out mod REDscript files in game files
uninstall-red:
    rm -rf '{{red_output_dir}}'

# 🗑️🗜️   clear out mod tweaks files in game files
uninstall-tweak:
    rm -rf '{{tweak_output_dir}}'

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
