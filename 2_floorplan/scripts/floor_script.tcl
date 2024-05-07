source -echo ../../../scripts/design_init.tcl

############################# Routing Directions ##################################

set_attribute [get_layers M1] routing_direction vertical
set_attribute [get_layers M2] routing_direction horizontal
set_attribute [get_layers M3] routing_direction vertical
set_attribute [get_layers M4] routing_direction horizontal
set_attribute [get_layers M5] routing_direction vertical
set_attribute [get_layers M6] routing_direction horizontal
set_attribute [get_layers M7] routing_direction vertical
set_attribute [get_layers M8] routing_direction horizontal
set_attribute [get_layers M9] routing_direction vertical
set_attribute [get_layers MRDL] routing_direction horizontal


#./output/ChipTop_pads.v
initialize_floorplan \
-control_type core \
  -core_utilization 0.6 \
  -flip_first_row true \
  -core_offset {12.4 12.4 12.4 12.4}
   # -boundary {{0 0} {700 700}} \
###########################################################################
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

######################## place pins with constraints ######################

set_block_pin_constraints -allowed_layers {M3 M4 M5} -pin_spacing 8 -self
place_pins -ports [get_ports *] -self

set MIN_ROUTING_LAYER            "M1"   ;# Min routing layer
set MAX_ROUTING_LAYER            "M9"   ;# Max routing layer

set_ignored_layers \
    -min_routing_layer  $MIN_ROUTING_LAYER \
    -max_routing_layer  $MAX_ROUTING_LAYER

#######################inserting eell tap cells#####################################


create_tap_cells -lib_cell [get_lib_cell saed14rvt_ss0p6vm40c/SAEDRVT14_TAPDS] -distance 30 -pattern stagger

##############################################################################################
###############################################################################################

create_net -power $NDM_POWER_NET
create_net -ground $NDM_GROUND_NET 

connect_pg_net -net $NDM_POWER_NET [get_pins -hierarchical "*/VDD*"]
connect_pg_net -net $NDM_GROUND_NET [get_pins -hierarchical "*/VSS"]

##############################  floorplanning initial placement ####################

create_placement -floorplan -timing_driven
legalize_placement


##############################  Reports  #############################

report_qor > ../reports/qor.rpt
report_timing -delay_type max -max_paths 20 > ../reports/setupdelay.rpt
report_timing -scenarios func_slow -max_paths 20 > ../reports/setup.rpt
write_sdc  -output ../sdc/$DESIGN_TOP.sdc

save_block -as ${DESIGN_NAME}_floorplaned
