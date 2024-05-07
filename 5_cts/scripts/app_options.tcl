#set_app_option -name route.common.connect_within_pins_by_layer_name -value {{M1 via_standard_cell_pins} {M2 via_standard_cell_pins}}



#create_routing_rule ROUTE_RULES_1 -multiplier_spacing 2 -multiplier_width 2
#set_clock_routing_rules -rules ROUTE_RULES_1 -min_routing_layer M3  -max_routing_layer M5
#create_routing_rule ROUTE_RULES_1 \
  #-widths {M3 0.17 M4 0.3 } \
 # -spacings {M3 0.04 M4 0.04 }
#set_clock_routing_rules -rules ROUTE_RULES_1 -min_routing_layer M1 -max_routing_layer M6



# clock_opt -from final_opto               #optimization


## size_cell core_region_i/RISCV_CORE/ex_stage_i/alu_i/U294 -lib_cell saed14rvt_ss0p6vm40c/SAEDRVT14_AN3_2
#route_eco -nets {n1 n2 n3}
#set_clock_routing_rules -min_routing_layer M3 -max_routing_layer M5 -default_rule
#set_clock_uncertainty -hold 0.05 [all_clocks]
