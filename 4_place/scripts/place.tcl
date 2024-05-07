####################################################################################
###################################  PLACEMENT  ###################################
####################################################################################
### get the last powerplan run 
set design pulpino_top
puts "latest powerplanning run will be used for input data"

set base_path "/home/ICer/GP/PULPino/3_powerplan/runs"
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

#####################OPEN POWERPLANNED BLOCKED#####################
open_block -edit $DESIGN_NAME:${DESIGN_NAME}_powerplanned

link

source /home/ICer/GP/PULPino/1_syn/scripts/dont_use_cells.tcl
puts "########start_place#########"

############################################################################################################################
###############################Pre place checks##########################
remove_corners estimated_corner
set_scenario_status func_slow -hold false 
set_scenario_status -setup false  func_fast
check_design -checks pre_placement_stage
check_design -checks physical_constraints 
analyze_lib_cell_placement -lib_cells *

#######################################################################################################################################
###############################################################################
##################################PLACMENT BEGINS##############################
remove_ideal_network -all
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name time.disable_recovery_removal_checks -value false
set_app_options -name time.disable_case_analysis -value false
set_app_options -name opt.common.user_instance_name_prefix -value place

###############################################################################
place_opt
legalize_placement

#################################Saving and Reporting#############################
check_legality -verbose > ../reports/check_legality.rpt
report_timing -nosplit -delay_type max -max_paths 10 > ../reports/timing_max_place.rpt
report_timing -nosplit -delay_type min > ../reports/timing_min_place.rpt
report_qor > ../reports/qor.rpt
report_utilization > ../reports/utilization.rpt
check_pg_drc > ../reports/check_pg_drc.rpt

save_block -as ${DESIGN_NAME}_placed



