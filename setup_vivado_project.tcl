# 1. Define Paths relative to this script
# [file normalize [file dirname [info script]]] gets the path to the `build` folder
# Use the following two lines if the script exists outside the `build` folder
set root_dir [file normalize [file dirname [info script]]]
set build_dir [file join $root_dir "build"]
# Use the following two lines if the script exists inside the `build` folder
# set build_dir [file normalize [file dirname [info script]]]
# set root_dir  [file join $build_dir ".."]
set src_dir   [file join $root_dir "src"]
set constr_dir [file join $root_dir "constr"]
# set src_dir   [file join $root_dir "src" "hdl"]
# set tb_dir    [file join $root_dir "src" "tb"]
# set constr_dir [file join $root_dir "src" "constr"]

# 2. Define Project Variables (Change these for new projects)
set project_name "sqrt8_project"
set part_number  "xc7z020clg484-1"
set top_module   "sqrt8"
set testbench    "tb_sqrt8"

# 3. Create the project inside the build folder
create_project -force $project_name "$build_dir/$project_name" -part $part_number
set_property target_language VHDL [current_project]
# set_property vhdl_define "" [current_fileset]

# 4. Add all .vhd files from hdl and tb subfolders automatically
# Add source files: *.vhd but not starting with tb_
add_files -norecurse [glob -nocomplain [file join $src_dir *.vhd] | grep -v {/tb_.*\.vhd$}]
# Add testbench files: tb_*.vhd
add_files -fileset sim_1 -norecurse [glob -nocomplain [file join $src_dir tb_*.vhd]]
# add_files -norecurse [glob [file join $src_dir *.vhd]]
# add_files -fileset sim_1 -norecurse [glob [file join $tb_dir *.vhd]]
add_files -fileset constrs_1 -norecurse [glob [file join $constr_dir *.xdc]]

# 5. Set Top Levels
set_property top $top_module [current_fileset]
set_property top $testbench [get_filesets sim_1]

# 6. Run Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# puts "SUCCESS: $project_name created and synthesized in $build_dir."
puts "SUCCESS: Project $project_name created in $build_dir."