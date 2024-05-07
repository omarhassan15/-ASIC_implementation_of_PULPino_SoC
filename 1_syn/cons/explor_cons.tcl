
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

##############################################################################################
                             ##########################################


####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs
define_name_rules no_case -case_insensitive
change_names -rule no_case -hierarchy
change_names -rule verilog -hierarchy
set verilogout_no_tri true
set verilogout_equation false
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### # REF CLOCK (100 MHz)
# master CLOCK 
set CLK1_NAME clk
set CLK1_PER 4

#2. spi_clk CLOCK 
set CLK2_NAME spi_clk_i
set CLK2_PER 2

#3. tck_i CLOCK 
set CLK3_NAME tck_i
set CLK3_PER 2

# Skew
set CLK_SETUP_SKEW 0.06
set CLK_HOLD_SKEW 0.05


# 1. Master Clock Definitions 
create_clock -name $CLK1_NAME -period $CLK1_PER -waveform "0 [expr $CLK1_PER/2]" [get_ports clk]
create_clock -name $CLK2_NAME -period $CLK2_PER -waveform "0 [expr $CLK2_PER/2]" [get_ports spi_clk_i]
create_clock -name $CLK3_NAME -period $CLK3_PER -waveform "0 [expr $CLK2_PER/2]" [get_ports tck_i]

set_dont_touch_network [get_clocks "clk spi_clk_i tck_i"]

# 2. Generated Clock Definitions
create_generated_clock -master_clock spi_clk_i -source [get_ports spi_clk_i] \
-name "inverted_spi_slave_CLK" [get_port peripherals_i/axi_spi_slave_i/axi_spi_slave_i/u_txreg/clk_inv_i/clk_o] \
-invert -divide_by 1

create_generated_clock -master_clock tck_i -source [get_ports tck_i] \
-name "inverted_adbg_CLK" [get_port core_region_i/adv_dbg_if_i/cluster_tap_i/u_clk_inv/clk_o] \
-invert -divide_by 1

set_dont_touch_network [get_clocks "inverted_spi_slave_CLK inverted_adbg_CLK"]


#create_generated_clock -master_clock clk -source [get_ports {clk}] -name "gated_clocks" [get_pins -hierarchical {clk_en_reg/Q}] -divide_by 1

# 3. Clock Latencies

# 4. Clock Uncertainties
set_clock_uncertainty -setup $CLK_SETUP_SKEW [all_clocks]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [all_clocks]

# 5. Clock Transitions
###################reporting clocks#####################"
report_clocks 
####################################################################################
####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################
set_clock_groups -asynchronous \
                 -group { clk gated_clocks} \
                 -group { spi_clk_i inverted_spi_slave_CLK} \
                 -group { tck_i inverted_adbg_CLK}
####################################################################################
           #########################################################
             #### Section 3 : set input/output delay on ports ####
           #########################################################
####################################################################################

set in_delay_1  [expr 0.01*$CLK1_PER]
set out_delay_1 [expr 0.01*$CLK1_PER]

set in_delay_2  [expr 0.003*$CLK2_PER]
set out_delay_2 [expr 0.003*$CLK2_PER]

#####################Constrain Input Paths##############################
set_input_delay $in_delay_1 -clock clk [get_ports fetch_enable_i ]
set_input_delay $in_delay_1 -clock clk [get_ports scl_pad_i]
set_input_delay $in_delay_1 -clock clk [get_ports sda_pad_i]
set_input_delay $in_delay_1 -clock clk [get_ports uart_rx]
set_input_delay $in_delay_1 -clock clk [get_ports uart_cts]
set_input_delay $in_delay_1 -clock clk [get_ports uart_dsr]
set_input_delay $in_delay_1 -clock clk [get_ports gpio_in]

set_input_delay $in_delay_1 -clock clk [get_ports spi_master_sdi0_i]
set_input_delay $in_delay_1 -clock clk [get_ports spi_master_sdi1_i]
set_input_delay $in_delay_1 -clock clk [get_ports spi_master_sdi2_i]
set_input_delay $in_delay_1 -clock clk [get_ports spi_master_sdi3_i]

set_input_delay $in_delay_2 -clock spi_clk_i [get_ports spi_sdi0_i ]
set_input_delay $in_delay_2 -clock spi_clk_i [get_ports spi_sdi1_i ]
set_input_delay $in_delay_2 -clock spi_clk_i [get_ports spi_sdi2_i ]
set_input_delay $in_delay_2 -clock spi_clk_i [get_ports spi_sdi3_i ]
set_input_delay $in_delay_2 -clock spi_clk_i [get_ports spi_cs_i]

set_input_delay $in_delay_2 -clock tck_i [get_ports trstn_i]
set_input_delay $in_delay_2 -clock tck_i [get_ports tms_i]
set_input_delay $in_delay_2 -clock tck_i [get_ports tdi_i]

#####################Constrain output Paths##############################

set_output_delay $out_delay_1 -clock clk [get_ports spi_master_clk_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_csn0_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_csn1_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_csn2_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_csn3_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_sdo0_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_sdo1_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_sdo2_o]
set_output_delay $out_delay_1 -clock clk [get_ports spi_master_sdo3_o]

set_output_delay $out_delay_1 -clock clk [get_ports scl_pad_o]
set_output_delay $out_delay_1 -clock clk [get_ports scl_padoen_o]
set_output_delay $out_delay_1 -clock clk [get_ports sda_pad_o]
set_output_delay $out_delay_1 -clock clk [get_ports sda_padoen_o]

set_output_delay $out_delay_1 -clock clk [get_ports uart_tx]
set_output_delay $out_delay_1 -clock clk [get_ports uart_rts]
set_output_delay $out_delay_1 -clock clk [get_ports uart_dtr]

set_output_delay $out_delay_1 -clock clk [get_ports gpio_out]
set_output_delay $out_delay_1 -clock clk [get_ports gpio_dir]
set_output_delay $out_delay_1 -clock clk [get_ports gpio_padcfg]

set_output_delay $out_delay_2 -clock spi_clk_i [get_ports spi_sdo0_o]
set_output_delay $out_delay_2 -clock spi_clk_i [get_ports spi_sdo1_o]
set_output_delay $out_delay_2 -clock spi_clk_i [get_ports spi_sdo2_o]
set_output_delay $out_delay_2 -clock spi_clk_i [get_ports spi_sdo3_o]

set_output_delay $out_delay_2 -clock tck_i [get_ports tdo_o]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

#set_driving_cell -library saed14rvt_ss0p6vm40c -lib_cell SAEDRVT14_BUF_4 -pin X [remove_from_collection [all_inputs] [all_clocks]]



####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################
set_load -max 0.05  [all_outputs]
set_load -min 0.005  [all_outputs]
set_max_fanout 20 [current_design]
####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis
set_operating_conditions  -min_library "saed14rvt_ff0p88v25c" -min "ff0p88v25c" -max_library "saed14rvt_ss0p6vm40c" -max "ss0p6vm40c"

set_wire_load_model -name 35000 -library saed14rvt_ss0p6vm40c

################################# define case analysis:###################################
#set_case_analysis 0 [get_ports testmode_i]

####################################################################################







