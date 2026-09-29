// Setting for async/sync reset (depend on FPGA/ASIC implemenation)
`define __RST_SENS__  //or negedge rst_n
// `define __LIF_V1_0__ 1
`define __NO_LEARNING__ 1
// set this parameter to let the RAM interface of weight as output
// `define __EXT_RAM_INF__ 1
`define STATE_WIDTH 3
`define SPK_ARRAY_WIDTH 784 // should be similar to number of neural 
// `define WEIGHT_ADDR_WIDTH 3
`define WEIGHT_ADDR_WIDTH 10
`define OUTPUT_ARRAY_WIDTH 10
`define NEURAL_ARRAY_WIDTH 48
// for RAM model
`define RAM_MODEL sram_sp_w8_b1024_freepdk45
`define RAM_DW data_0_WIDTH
`define RAM_AW ADDR_WIDTH
`define RAM_DP RAM_DEPTH

////////////////////////////////////////////////////////////////////////////////
// State declarations
////////////////////////////////////////////////////////////////////////////////
`define ST_IDLE          `STATE_WIDTH'd0
`define ST_DOWNLD_SPIKE  `STATE_WIDTH'd1
`define ST_GENSPK_A_COM  `STATE_WIDTH'd2
`define ST_LEAK          `STATE_WIDTH'd3
`define ST_FIRE          `STATE_WIDTH'd4
`define ST_UPLD_SPIKE    `STATE_WIDTH'd5

// old state:
`ifdef __LIF_V1_0__
`define ST_LEAK_A_FIRE `STATE_WIDTH'd3
`endif

//pragma

`define PRAGMA_SYN_OFF sysnopsy synthesis_off
`define PRAGMA_SYN_ON sysnopsy synthesis_on