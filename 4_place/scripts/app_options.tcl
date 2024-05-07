##############################Design Requiremnts ########################
#set_attribute -objects [get_lib_cells */*TAP*] -name dont_touch -value true
#set_app_options -name opt.power.mode -value total
#set_placement_spacing_label -name x  -side both -lib_cells [get_lib_cells -of [get_cells *]]
#set_placement_spacing_rule -labels {x x} {0 1}
#report_placement_spacing_rules
##############################Qor Setup ################################### 
#set_app_options -name place.legalize.optimize_pin_access_using_cell_spacing -value false
#set_app_options -name place.legalize.stream_place -value true
#set_app_options -name place.coarse.max_density -value 0.1
#set_app_option -name place.legalize.avoid_pins_under_preroute_layers -value {M1 M2}
#set_app_option -name place.legalize.avoid_pins_under_preroute_libpins -value {M1 M2}
 #### Congestion
#set_app_options -name place.opt.congestion_effort -value high
#set_app_options -name place.opt.final_place.effort -value high
#create_placement -congestion -congestion_effort high
set_app_options -name place.legalize.optimize_pin_access_using_cell_spacing -value true

