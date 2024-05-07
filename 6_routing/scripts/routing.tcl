####################################################################################
###################################  ROUTING ##########################################
####################################################################################

############################################################
### get the last CTS run 
puts "latest CTS run will be used for input data"


set base_path "/home/ICer/GP/PULPino/5_cts/runs"
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

#####################OPEN CTSed BLOCKED#####################
open_block -edit $DESIGN_NAME:${DESIGN_NAME}_ctsed

link
###############################################################################
###############################################################################
##################################ROUTING BEGINS###################################
connect_pg_net -net "VDD" [get_pins -hierarchical "*/VDD"]
connect_pg_net -net "VSS" [get_pins -hierarchical "*/VSS"]

set MIN_ROUTING_LAYER            "M1"   ;# Min routing layer
set MAX_ROUTING_LAYER            "M9"   ;# Max routing layer


remove_ignored_layers -all
set_ignored_layers \
    -min_routing_layer  $MIN_ROUTING_LAYER \
    -max_routing_layer  $MAX_ROUTING_LAYER

######################### Checkers_befor_routes#########################
check_routability > ../reports/check_routability.rpt
check_design -checks pre_route_stage > ../reports/check_pre_route.rpt

##################################################################
set_app_options -name route.global.effort_level	 -value high
route_global
route_track
save_block -as ${DESIGN_NAME}_routed_track
route_detail  
route_opt

######################## Saving&& Reporting###############

save_block -as ${DESIGN_NAME}_routed
report_qor > ../reports/qor.rpt
check_lvs -max 5000 > ../reports/lvs.rpt
report_utilization > ../reports/utilization.rpt
report_timing -nosplit -delay_type max > ../reports/timing_max_route.rpt
report_timing -nosplit -delay_type min > ../reports/timing_min_route.rpt

