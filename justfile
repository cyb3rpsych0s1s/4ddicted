# installation dir for Cyberpunk 2077, e.g. Steam
game_dir := join("C:\\", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")
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

# list all commands
default:
  @just --list

# create mod folders (if not exists) in game files
setup:
    mkdir -p '{{cet_output_dir}}'
    mkdir -p '{{red_output_dir}}'

# clear current mod files in game files
uninstall: uninstall-archive uninstall-cet uninstall-red uninstall-tweak

# clear current archive files in game files
uninstall-archive:
    rm -f '{{archive_output_dir}}'/Addicted.archive
    rm -f '{{archive_output_dir}}'/Addicted.archive.xl

# clear current CET files in game files
uninstall-cet:
    rm -rf '{{cet_output_dir}}'

# clear current REDscript files in game files
uninstall-red:
    rm -rf '{{red_output_dir}}'

# clear current tweaks files in game files
uninstall-tweak:
    rm -rf '{{tweak_output_dir}}'

# clear current cache
clear:
    rm -rf '{{ join(red_cache_dir, "modded") }}'/.
    cp -f '{{ join(red_cache_dir, "final.redscripts.bk") }}' '{{ join(red_cache_dir, "final.redscripts") }}'
    rm -f '{{ join(red_cache_dir, "final.redscripts.bk") }}'

# copy codebase files to game files (excluding archive, use hot reload during dev instead)
rebuild:
    cp -r '{{cet_input_dir}}'/. '{{cet_output_dir}}'
    cp -r '{{red_input_dir}}'/. '{{red_output_dir}}'
    cp -r '{{tweak_input_dir}}'/. '{{tweak_output_dir}}'

# copy codebase files to game files (including archive)
build: rebuild
    cp -r '{{archive_input_dir}}'/. '{{game_dir}}'

# show logs from CET and RED
logs:
    echo "\n=== TweakXL ===\n" && \
    cat '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}' && \
    echo "\n=== CET ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' && \
    echo "\n=== REDscript ===\n" && \
    cat '{{ join(game_dir, "r6", "logs", "redscript.log") }}' && \
    echo "\n=== Toxicity ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'

# store (or overwrite) logs in latest.log
store:
    (just logs)  > 'latest.log'

# clear out logs
erase: clear
    rm -f '{{ join(game_dir, "red4ext", "plugins", "TweakXL", "TweakXL.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' \
    '{{ join(game_dir, "r6", "logs", "redscript.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'

# assemble book pages for release
assemble:
    mdbook build

# read book pages directly
read:
    mdbook build --open

# hot reload changes in book
draft:
    mdbook watch

# bundle for release
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