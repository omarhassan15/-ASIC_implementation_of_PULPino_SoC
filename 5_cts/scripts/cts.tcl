####################################################################################
###################################  CTS  ##########################################
####################################################################################

############################################################
### get the last placment run 
puts "latest placment run will be used for input data"

set base_path "/home/ICer/GP/PULPino/4_place/runs"
set latest_run ""
set latest_run_number 0

# Get a list of directories in the base path
set directories [glob -type d "${base_path}/*"]

# Iterate through each directory
foreach dir $directories {
    # Extract the run number from the directory name
    set run_number [file tail $dir]

    # If the directory name matches the pattern "run_<number>", extract the number
    if {[regexp {run_(\d+)} $run_number - match run_number]} {
        # Check if the current run number is greater than the latest run number
        if {$run_number > $latest_run_number} {
            set latest_run_number $run_number
        }
    }
}

set DESIGN_NAME pulpino_top

set DLIB_PATH $dir/WORK/${DESIGN_NAME}

sh cp -r $DLIB_PATH .

set DLIB_PATH ./${DESIGN_NAME} 

############OPEN DLIB###############
open_lib $DLIB_PATH

#####################OPEN PLACED BLOCKED#####################
open_block -edit $DESIGN_NAME:${DESIGN_NAME}_placed

link
###############################################################################
###############################################################################
##################################CTS BEGINS###################################

set_dont_touch_network -clear [get_clocks clk]
set_dont_touch_network -clear [get_clocks spi_clk_i]
set_dont_touch_network -clear [get_clocks tck_i]
set_dont_touch_network -clear [get_clocks inverted_spi_slave_CLK]
set_dont_touch_network -clear [get_clocks inverted_adbg_CLK]

remove_tracks -all
create_track -layer M1 -coord 0.079 -space 0.074
create_track -layer M2 -coord 0.04  -space 0.06 
create_track -layer M3 -space 0.074 
create_track -layer M4 -space 0.074
create_track -layer M5 -space 0.12
create_track -layer M6 -space 0.12 
create_track -layer M7 -space 0.12  
create_track -layer M8 -space 0.12  
create_track -layer M9 -space 0.12 
create_track -layer MRDL -space 0.6
#########################  include inverters only to cts  ########################
set_dont_use [get_lib_cells */*_INV_S_16*]
set_dont_use [get_lib_cells */*_INV_S_20*]
set_dont_use [get_lib_cells */*_INV_S_10*]
set_dont_use [get_lib_cells */*_INV_S_12*]
set_dont_use [get_lib_cells */*_BUF*]
set_dont_use [get_lib_cells */*_DEL_R2V3_2*]
set_lib_cell_purpose -exclude cts [get_lib_cells]

set_lib_cell_purpose -include cts */*_INV_S_1*
set_lib_cell_purpose -include cts */*_INV_S_2*
set_lib_cell_purpose -include cts */*_INV_S_3*
set_lib_cell_purpose -include cts */*_INV_S_4*
set_lib_cell_purpose -include cts */*_INV_S_5*
set_lib_cell_purpose -include cts */*_INV_S_6*
set_lib_cell_purpose -include cts */*_INV_S_7*
set_lib_cell_purpose -include cts */*_INV_S_8*
set_lib_cell_purpose -include cts */*_DELPROGS9_V1_*
set_lib_cell_purpose -include cts */*_DELPROGS9_V2_*
#set_lib_cell_purpose -include cts */*_INV_S_9*
#set_lib_cell_purpose -include cts */*_INV_S_10*
set_lib_cell_purpose -exclude cts */*_INV_S_20*
########################checkers pre cts ###################
check_design -checks pre_clock_tree_stage
set_app_options \-name cts.common.user_instance_name_prefix -value "CTS_"

################################################3
remove_ignored_layers -all
set_ignored_layers -min_routing_layer  M2 -max_routing_layer  M6
create_routing_rule ROUTE_RULES_1 -multiplier_spacing 2 -multiplier_width 2
set_clock_routing_rules -rules ROUTE_RULES_1 -min_routing_layer M2  -max_routing_layer M5
set_clock_tree_options -target_latency 0.000 -target_skew 0.000 
set cts_enable_drc_fixing_on_data true
set_app_options -name clock_opt.hold.effort -value high
clock_opt

write_verilog ../netlists/${DESIGN_NAME}.cts.gate.v
report_clock_timing  -type skew > ../reports/${DESIGN_NAME}.clock_skew.rpt

set_propagated_clock [get_clocks clk]
set_propagated_clock [get_clocks spi_clk_i]
set_propagated_clock [get_clocks tck_i]


#################################Saving and Reporting#########################
save_block -as ${DESIGN_NAME}_ctsed
report_clock_qor -type area > ../reports/clock_area.rpt
report_qor > ../reports/qor.rpt
report_utilization > ../reports/utilization.rpt
report_timing -nosplit -delay_type min -max_paths 10 > ../reports/timing_min_cts.rpt
report_timing -nosplit -delay_type max -max_paths 10 > ../reports/timing_max_cts.rpt
check_pg_drc > ../reports/check_pg_drc.rpt



