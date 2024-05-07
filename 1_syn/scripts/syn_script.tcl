##################### Define Working Library Directory ######################
#sh rm -rf work
#sh mkdir -p work
define_design_lib work -path ./work

set CONS_PATH    "/home/ICer/GP/PULPino/1_syn/cons"
set RUN_PATH	 "/home/ICer/GP/PULPino/1_syn/runs/run_7"
set RVT_DB_PATH  "/mnt/hgfs/techfiles/SAED14nm_EDK_CORE_RVT_v_062020/stdcell_rvt/db_nldm"
set lVT_DB_PATH  "/mnt/hgfs/techfiles/SAED14nm_EDK_CORE_LVT_v_062020/stdcell_lvt/db_nldm"
set HVT_DB_PATH  "/mnt/hgfs/techfiles/SAED14nm_EDK_CORE_HVT_v_062020/stdcell_hvt/db_nldm"
set RTL_path     "/home/ICer/GP/PULPino/rtl"

#set TTLIB 	"$RVT_DB_PATH/saed14rvt_tt0p8v25c.db"
set FFLIB0 	"$RVT_DB_PATH/saed14rvt_ff0p88v25c.db" 
#set FFLIB1 	"$lVT_DB_PATH/saed14rvt_ff0p88v25c.db" 
#set FFLIB2 	"$HVT_DB_PATH/saed14rvt_ff0p88v25c.db" 

set SSLIB0 	"$RVT_DB_PATH/saed14rvt_ss0p6vm40c.db" 
#set SSLIB1 	"$lVT_DB_PATH/saed14lvt_ss0p6vm40c.db" 
#set SSLIB2 	"$HVT_DB_PATH/saed14hvt_ss0p6vm40c.db"                                        
###########################Addingsearchpath########################

lappend search_path "$RVT_DB_PATH $lVT_DB_PATH $HVT_DB_PATH"                                    
lappend search_path $RTL_path 

###########################DefineTopModule########################

set top_module pulpino_top

############################# Formality Setup File ##########################
                                                   
set_svf $top_module.svf
################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries          #"
puts "###########################################"


## Standard Cell libraries 

set target_library 	 [list $SSLIB0 $FFLIB0]
set link_library 	 [list * $SSLIB0 $FFLIB0]
##########################Don't use cells############################
source -echo -verbose /home/ICer/GP/PULPino/1_syn/scripts/dont_use_cells.tcl

######################## Elaboration #################################



source -echo /home/ICer/GP/PULPino/1_syn/scripts/elaborate_PULPino.tcl


#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design > design_checks.log

#################### Define Design Constraints #########################
puts "###############################################"
puts "############ Design Constraints #### ##########"
puts "###############################################"

source -verbose -echo $CONS_PATH/explor_cons.tcl

check_timing

################ creating DFT Ports and Clock ######################
puts "###############################################"
puts "####### creating DFT Signals and Clock #########"
puts "###############################################"
create_port scan_clk -direction in
create_port scan_rst -direction in
#create_port scan_mode -direction in
#create_port scan_in -direction in
#create_port scan_out -direction out

create_clock -name s_clk -period 100 -waveform {0 50} [get_ports scan_clk]

###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"

compile -scan 

###################### set DFT Configrations ##########################
puts "###############################################"
puts "########## set DFT Configrations #############"
puts "###############################################"


set_app_var test_default_delay 0
set_app_var test_default_bidir_delay 0
set_app_var test_default_strobe 40
set_app_var test_default_period 100
#set_scan_configuration -style multiplexed_flip_flop

############################################################################
# DFT Preparation Section
############################################################################

set flops_per_chain 100
set num_flops [sizeof_collection [all_registers -edge_triggered]]
set num_chains [expr $num_flops / $flops_per_chain + 1 ]
set_scan_configuration -chain_count $num_chains

###################### set DFT Signals and Type #####################
puts "###############################################"
puts "########## set DFT Signals and Type #############"
puts "###############################################"

set_dft_signal  -type ScanClock   -port [get_ports scan_clk]   -view existing_dft -timing [list 45 55]   
set_dft_signal  -type Reset       -port [get_ports scan_rst]   -view spec         -active_state 0
set_dft_signal  -type ScanEnable  -port [get_ports scan_enable_i]  -view existing_dft 
set_dft_signal  -type TestMode    -port [get_ports testmode_i]  -view spec         -active_state 1
set_dft_signal  -type Constant    -port [get_ports testmode_i]  -view existing_df  -active_state 1
set_dft_signal  -type ScanDataIn  -port [get_ports scan_i]    -view spec
set_dft_signal  -type ScanDataOut -port [get_ports scan_o]   -view spec

###################### Creating Test Protocol #####################
puts "###############################################"
puts "########## Creating Test Protocol #############"
puts "###############################################"

create_test_protocol

###################### DFT insertion and Checks #####################
puts "###############################################"
puts "########## DFT insertion and Checks #############"
puts "###############################################"

dft_drc
insert_dft
######################  second optimization #####################
puts "###############################################"
puts "##########  second optimization #############"
puts "###############################################"


compile_ultra -incremental -scan

##################### Close Formality Setup file ###########################

set_svf -off


#############################################################################
# Write out files
#############################################################################
group_path -name input -from [all_inputs]
group_path -name outputs -to [all_outputs]
group_path -name comb -from [all_inputs] -to [all_outputs]
report_timing



define_name_rules  no_case -case_insensitive
change_names -rule no_case -hierarchy
change_names -rule sverilog -hierarchy
set verilogout_no_tri	 true
set verilogout_equation  false

write_file -format verilog -hierarchy -output ../netlists/$top_module.ddc
write_file -format verilog -hierarchy -output ../netlists/$top_module.v
write_sdf  ../sdf/$top_module.sdf
write_sdc  -nosplit ../sdc/$top_module.sdc
write_scan_def -output ../netlists/$top.scandef
write_icc2_files -output ../icc2_files/
####################### reporting ##########################################

report_area -hierarchy > ../reports/area.rpt
report_power -hierarchy > ../reports/power.rpt
report_timing -delay_type max -max_paths 20 > ../reports/setup.rpt
report_clock -attributes > ../reports/clocks.rpt
report_constraint -all_violators -nosplit > ../reports/constraints.rpt
dft_drc -verbose -coverage_estimate >> ../reports/dft.rpt
#exit
