# installation dir for Cyberpunk 2077, e.g. Steam
game_dir := join("C:\\", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")
alt_game_dir := '../../../Program Files (x86)/Steam/steamapps/common/Cyberpunk 2077'

# codebase (outside of game files)
cet_input_dir := join("mods", "Addicted")
red_input_dir := join("scripts", "Addicted")

# game files
cet_output_dir := join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted")
red_output_dir := join(game_dir, "r6", "scripts")

# REDscript CLI
cli := join("tools", "redmod", "bin", "redMod.exe")

# create mod folders (if not exists) in game files
setup:
    mkdir -p '{{cet_output_dir}}'
    mkdir -p '{{red_output_dir}}'

# clear current mod files in game files
uninstall:
    rm -rf '{{cet_output_dir}}'
    rm -rf '{{red_output_dir}}'

# clear current cache
clear:
    rm -rf '{{ join(game_dir, "r6", "cache", "modded") }}'

# copy codebase files to game files
build:
    cp -r '{{cet_input_dir}}'/. '{{cet_output_dir}}'
    cp '{{red_input_dir}}'/'Addicted.reds' '{{red_output_dir}}'/'Addicted.reds'

# copy codebase files to remote shared folder
# FIXME: remote user domain ip:
# FIXME: curl -T "{$(echo * | tr ' ' ',')}" -u '{{domain}}\{{user}}' smb://{{ip}}/Addicted/mods/Addicted
# FIXME: curl -T '{{red_input_dir}}'/'Addicted.reds' -u '{{domain}}\{{user}}' smb://{{ip}}/Addicted/scripts/Addicted/Addicted.reds

# deploy mods in game files (with specified order)
deploy:
    (cd "{{game_dir}}" && '{{cli}}' deploy -root=. -mod=nativeSettings,Toxicity,'WE3D - Drugs of Night City',Addicted)

# show logs from CET and RED
logs:
    echo "\n=== CET ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' && \
    echo "\n=== REDscript ===\n" && \
    cat '{{ join(game_dir, "r6", "logs", "redscript.log") }}' && \
    echo "\n=== Toxicity ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Toxicity", "Toxicity.log") }}'
    echo "\n=== Addicted ===\n" && \
    cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'
# echo "\n=== WE3D - Drugs of Night City ===\n" && \
# cat '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "WE3D - Drugs of Night City", "WE3D - Drugs of Night City.log") }}'

# store (or overwrite) logs in latest.log
store:
    (just logs)  > 'latest.log'

# clear out logs
erase: clear
    rm -f '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "scripting.log") }}' \
    '{{ join(game_dir, "r6", "logs", "redscript.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Toxicity", "Toxicity.log") }}' \
    '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "Addicted", "Addicted.log") }}'
# '{{ join(game_dir, "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "WE3D - Drugs of Night City", "WE3D - Drugs of Night City.log") }}' \

# shortcut for red cli
cli *args="":
    '{{cli}}' {{args}}
