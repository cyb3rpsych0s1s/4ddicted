game_dir := "C:/Program Files (x86)/Steam/steamapps/common/Cyberpunk 2077"
cet_mod_dir := "mods/Addicted"
cet_output_dir := game_dir/"bin/x64/plugins/cyber_engine_tweaks"/cet_mod_dir
red_output_dir := game_dir/cet_mod_dir/"scripts"
old_red_output_dir := game_dir/"r6/scripts"
redmod_exec := game_dir/"tools/redmod/bin/redMod.exe"

# exe := "C:\\Program\ Files\ \(x86\)\\Steam\\steamapps\\common\\Cyberpunk\ 2077\\tools\\redmod\\bin\\redMod.exe"
# root := "C:\\Program\ Files\ \(x86\)\\Steam\\steamapps\\common\\Cyberpunk\ 2077"
root := join("C:", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")
exe := join(root, "tools", "redmod", "bin", "redMod.exe")

cet_input_dir := cet_mod_dir
red_input_dir := "scripts/Addicted"

setup:
    mkdir -p '{{cet_output_dir}}'
    mkdir -p '{{red_output_dir}}'

clean:
    rm -rf '{{cet_output_dir}}'
    rm -rf '{{red_output_dir}}'

build:
    cp -r '{{cet_input_dir}}'/. '{{cet_output_dir}}'
    cp '{{red_input_dir}}'/'Addicted.reds' '{{old_red_output_dir}}'/'Addicted.reds'
    # cp -r '{{red_input_dir}}'/. '{{red_output_dir}}'

deploy:
    '{{exe}}' deploy -root="{{root}}" -mod='nativeSettings','Toxicity','WE3D - Drugs of Night City','Addicted'
