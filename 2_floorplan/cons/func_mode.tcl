# master CLOCK 
set CLK1_NAME clk
set CLK1_PER 10

#2. spi_clk CLOCK 
set CLK2_NAME spi_clk_i
set CLK2_PER 4

#3. tck_i CLOCK 
set CLK3_NAME tck_i
set CLK3_PER 6



# 2.Clock Definitions

create_clock -name $CLK1_NAME -period $CLK1_PER -waveform "0 [expr $CLK1_PER/2]" [get_ports clk]
create_clock -name $CLK2_NAME -period $CLK2_PER -waveform "0 [expr $CLK2_PER/2]" [get_ports spi_clk_i]
create_clock -name $CLK3_NAME -period $CLK3_PER -waveform "0 [expr $CLK3_PER/2]" [get_ports tck_i]

set_dont_touch_network [get_clocks "clk spi_clk_i tck_i"]

# 2.1 Generated Clock Definitions

create_generated_clock -master_clock spi_clk_i -source [get_ports spi_clk_i] \
-name "inverted_spi_slave_CLK" [get_port peripherals_i/axi_spi_slave_i/axi_spi_slave_i/u_txreg/clk_inv_i/clk_o] \
-invert -divide_by 1

create_generated_clock -master_clock tck_i -source [get_ports tck_i] \
-name "inverted_adbg_CLK" [get_port core_region_i/adv_dbg_if_i/cluster_tap_i/u_clk_inv/clk_o] \
-invert -divide_by 1

set_dont_touch_network [get_clocks "inverted_spi_slave_CLK inverted_adbg_CLK"]

# 3. Clock Latencies
# 4. Clock Uncertainties
#set_clock_uncertainty 0.05 [get_clocks CLK_I]
# 5. Clock Transitions
set_clock_groups -asynchronous \
                 -group { clk gated_clocks} \
                 -group { spi_clk_i inverted_spi_slave_CLK} \
                 -group { tck_i inverted_adbg_CLK}


