####################################################################################
###################################  CHIP_FINISHING ################################
####################################################################################

############################################################
### get the last routing run 
puts "latest placment run will be used for input data"

set base_path "/home/ICer/GP/PULPino/6_routing/runs"
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
open_block -edit $DESIGN_NAME:${DESIGN_NAME}_routed

link
###############################################################################
###############################################################################
##################################BEGIN CHIP FINISHING ########################

set GDS_MAP_FILE          	  "/mnt/hgfs/techfiles/SAED14nm_EDK_TECH_v_062020/tech/milkyway/saed14nm_1p9m_gdsout_mw.map"
set STD_CELL_GDS		  "/mnt/hgfs/techfiles/SAED14nm_EDK_CORE_RVT_v_062020/stdcell_rvt/gds/saed14rvt.gds"


#set pnr_DCAP_fillers "SAEDRVT14_DCAP*"
#set DCAP_fillers ""
#foreach DCAP $pnr_DCAP_fillers { lappend DCAP_fillers "*/${DCAP}" }

set pnr_DCAP_fillers "*/SAEDRVT14_DCAP_V4_64 */SAEDRVT14_DCAP_V4_32 */SAEDRVT14_DCAP_PV1ECO_18 */SAEDRVT14_DCAP_ECO_18 */SAEDRVT14_DCAP_V4_16 */SAEDRVT14_DCAP_ECO_15 \
*/SAEDRVT14_DCAP_PV1ECO_15 */SAEDRVT14_DCAP_PV1ECO_12 */SAEDRVT14_DCAP_ECO_12 */SAEDRVT14_DCAP_PV1ECO_9 */SAEDRVT14_DCAP_ECO_9 */SAEDRVT14_DCAP_V4_8 */SAEDRVT14_DCAP_PV1ECO_6 \
*/SAEDRVT14_DCAP_ECO_6 */SAEDRVT14_DCAP_V4_5 */SAEDRVT14_DCAP_PV3_3"
create_stdcell_filler -lib_cell $pnr_DCAP_fillers
connect_pg_net -automatic
remove_stdcell_fillers_with_violation

#set pnr_std_fillers "SAEDRVT14_FILL*"
#set std_fillers ""
#foreach filler $pnr_std_fillers { lappend std_fillers "*/${filler}" }

set pnr_std_fillers "*/SAEDRVT14_FILL_ECO_1 */SAEDRVT14_FILL2 */SAEDRVT14_FILL_ECO_2 */SAEDRVT14_FILL_NNWIV1Y2_2 */SAEDRVT14_FILL_NNWIY2_2 */SAEDRVT14_FILLP2 */SAEDRVT14_FILL_Y2_3 \
*/SAEDRVT14_FILL_NNWIV1Y2_3 */SAEDRVT14_FILL_NNWIY2_3 */SAEDRVT14_FILL_NNWVDDBRKY2_3 */SAEDRVT14_FILL3 */SAEDRVT14_FILL_ECO_3 */SAEDRVT14_FILLP3 */SAEDRVT14_FILL4 */SAEDRVT14_FILL5 \
*/SAEDRVT14_FILL_ECO_6 */SAEDRVT14_FILL_NNWSPACERY2_7 */SAEDRVT14_FILL_SPACER_7 */SAEDRVT14_FILL_ECO_9 */SAEDRVT14_FILL_ECO_12 */SAEDRVT14_FILL_ECO_15 */SAEDRVT14_FILL16 \
*/SAEDRVT14_FILL_ECO_18 */SAEDRVT14_FILL32 */SAEDRVT14_FILL64"
create_stdcell_filler -lib_cell $pnr_std_fillers
connect_pg_net -automatic

check_legality
check_routes
route_detail -incremental true -initial_drc_from_input true
############################################################
write_verilog ../results/pulpino_top.icc2.gate.v
report_qor > ../reports/qor.rpt
report_utilization > ../reports/utilization.rpt
report_timing > ../reports/timing.rpt  
report_power > ../reports/power.rpt
report_timing -delay_type min -path_type full -nosplit -max_paths 100 > ../reports/hold.rpt
############################################################
save_block -as ${DESIGN_NAME}_finished_all_clean


change_names -rules verilog -verbose
write_verilog \
	-include {pg_netlist unconnected_ports} \
	../output/${DESIGN_NAME}_finish.v

write_gds  -layer_map $GDS_MAP_FILE \
	  -keep_data_type \
	  -fill include \
	  -output_pin all \
	  -lib_cell_view frame \
	  -long_names \
	  ../output/${DESIGN_NAME}.gds

write_parasitics -output  {../output/${DESIGN_NAME}.spf}

close_block
close_lib

exit

}



report_timing -delay_type max -path_type full -nosplit -to peripherals_i/apb_spi_master_i/u_axiregs/spi_data_len_reg_6_ -from peripherals_i/apb_spi_master_i/u_axiregs/spi_data_len_reg_6_


















