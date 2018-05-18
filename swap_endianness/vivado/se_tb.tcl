set origin_dir "."
set orig_proj_dir "[file normalize "$origin_dir/project"]"
create_project se_tb $orig_proj_dir

set proj_dir [get_property directory [current_project]]

set obj [get_projects se_tb]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7vx690tffg1761-3" $obj
set_property "simulator_language" "Verilog" $obj

if {[string equal [get_filesets -quiet sim_1] ""]} {
  set sim_obj [create_fileset -simset sim_1]
} else {
  set sim_obj [get_filesets sim_1]
}
set files [list \
 "[file normalize "$origin_dir/hdl/swap_endianness.v"]"\
 "[file normalize "$origin_dir/sim/se_tb.v"]"\
 "[file normalize "$origin_dir/sim/se_tb.wcfg"]"\
]
add_files -norecurse -fileset $sim_obj $files
#import_files -norecurse -fileset $sim_obj $files

set_property -name {top} -value {se_tb} -objects $sim_obj
#set_property -name {xsim.simulate.xsim.more_options} -value {-view se_tb.wcfg} -objects $sim_obj
set_property -name {xsim.simulate.runtime} -value {120ns} -objects $sim_obj

launch_simulation
#xsim -runall -view se_tb_wcfg -verbose se_tb_behav
puts "Done!!!"
