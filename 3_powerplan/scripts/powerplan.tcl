####################################################################################
###################################  POWER PLAN  ###################################
####################################################################################
### get the last floorplanning run 
puts "latest floorplanning run will be used for input data"

set base_path "/home/ICer/GP/PULPino/2_floorplan/runs"

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

#####################OPEN FLOORPLANNED BLOCKED#####################
open_block -edit $DESIGN_NAME:${DESIGN_NAME}_floorplaned

link


## Defining Logical POWER/GROUND Connections
############################################
connect_pg_net -net "VDD" [get_pins -hierarchical "*/VDD*"]
connect_pg_net -net "VSS" [get_pins -hierarchical "*/VSS"]

####################### Master VIA Rules ###########################
remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all


set_pg_via_master_rule PG_VIA_3x1 -cut_spacing 0.25 -via_array_dimension {3 1}
set_app_options -name plan.pgroute.merge_shapes_for_via_creation -value false  

## Define Power Ring 
####################
create_pg_ring_pattern ring1 \
     -nets {VDD VSS} \
           -vertical_layer {M9} \
	   -vertical_width 5 \
	   -horizontal_layer {M8} \
           -horizontal_width 5\
           -horizontal_spacing 0.5 -vertical_spacing 0.5

set_pg_strategy ring1_s -core -pattern {{name: ring1} {nets: VDD VSS}} -extension {{stop: design_boundary_and_generate_pin}} 
compile_pg -strategies ring1_s

######### Create rail strategy #########################
create_pg_std_cell_conn_pattern rail_pattern -layers {M1} -rail_width {0.094}
set_pg_strategy rail_strat -pattern {{pattern: rail_pattern} {nets: VDD VSS}} -core
compile_pg -strategies rail_strat 



##########################Define Power Mesh 7 ###################### 
##############################################################

create_pg_mesh_pattern m7_mesh -layers {{{vertical_layer: M7} {width: 1 } {spacing: 4} {pitch: 20} {offset: 4}}}
set_pg_strategy m7_s -core -extension {{direction: T B L R} {stop: outermost_ring}} -pattern {{name: m7_mesh} {nets: VDD VSS}} 
compile_pg -strategies m7_s



################################### Create pg vias #########################
create_pg_vias -to_layers M7 -from_layers M1 -via_masters PG_VIA_3x1 -nets VDD
create_pg_vias -to_layers M7 -from_layers M1 -via_masters PG_VIA_3x1 -nets VSS
set_attribute -objects [get_vias -design pulpino_top -filter upper_layer_name=="M2"] -name via_def -value [get_via_defs -library [current_lib] VIA12BAR1]

############################# Define Power Mesh 8###########################
#########################################################
create_pg_mesh_pattern m8_mesh -layers {{{horizontal_layer: M8} {width: 1} {spacing: 4} {pitch: 20} {offset: 4}}}
set_pg_strategy m8_s -core -extension {{direction: T B L R} {stop: outermost_ring}} -pattern {{name: m8_mesh} {nets: VDD VSS}} 
compile_pg -strategies m8_s



connect_pg_net -net "VDD" [get_pins -hierarchical "*/VDD*"]
connect_pg_net -net "VSS" [get_pins -hierarchical "*/VSS"]

################# design checks ######################

check_pg_connectivity > ../reports/check_pg_connectivity.rpt
check_pg_missing_vias > ../reports/check_pg_missing_vias.rpt
check_pg_drc > ../reports/check_pg_drc.rpt

######################### saving Design & reporting #####################

save_block -as ${DESIGN_NAME}_powerplanned
report_qor > ../reports/qor.rpt














