/*
 * Project: NASH
 * Module: LIF_neuron
 * Version: 1.2 (signed voltage)
 */
`include "common.v"
`include "LIF.v"

module LIF_neuron
  #( 
     parameter WEIGHT_WIDTH   = 8,
     parameter LIF_NEURON_OVRFL_WIDTH = 8,
     parameter STATE_WIDTH    = `STATE_WIDTH,
     parameter OUTPUT_REG     = 0
     )(
`ifndef FIX_INTEFACE
       input                    clk,        // system clock
       input                    rst_n,      // system reset
       input [WEIGHT_WIDTH-1:0] i_wspike,   // input spike with weight
       input                    i_svalid,   // valid of spike
       input [STATE_WIDTH-1:0]  i_State,    // System State, for controlling  
       output [LIF_NEURON_OVRFL_WIDTH+WEIGHT_WIDTH-1:0] o_V,   // input spike with weight
       output                   o_spike,
       output                   TBD // for later configurations
`else
`endif
       );
   ////////////////////////////////////////////////////////////////////////////////
  // Wire/reg declarations
   ////////////////////////////////////////////////////////////////////////////////
   wire signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] w_acc_V_sum; // +1 for signal and under/overflow check
   wire signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] w_acc_V_ovflw; // +1 for signal and under/overflow check
   wire signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] w_acc_V_leak; // +1 for signal and under/overflow check
   wire signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] w_acc_V_leak_ovflw; // +1 for signal and under/overflow check
   wire signed [`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] 	 w_acc_V; // +1 for signal and under/overflow check

   reg signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0]  r_acc_V;// +1 for signal and under/overflow check
   wire 							 w_leak_en;
   wire 							 w_spike;
   wire signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] w_threshold;
   wire signed [1+`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] w_leak;

   ////////////////////////////////////////////////////////////////////////////////
   // Wire assignments
   ////////////////////////////////////////////////////////////////////////////////
   assign w_acc_V_sum  = (w_leak_en == 1'b0)? {r_acc_V[WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1],r_acc_V} + {{`LIF_NEURON_OVRFL_WIDTH+1{i_wspike[WEIGHT_WIDTH-1]}},i_wspike}:
			 r_acc_V ; // remove + `LIF_INV_LEAK
   assign w_acc_V_ovflw = (w_acc_V_sum[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH]==1'b0 && w_acc_V_sum[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1]==1'b1 )? {2'b00,{`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1{1'b1}} }: 
			  (w_acc_V_sum[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH]==1'b1 && w_acc_V_sum[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1]==1'b0 )? {2'b11,{`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1{1'b0}} }:w_acc_V_sum;
   assign w_acc_V_leak = (w_leak_en == 1'b0)?w_acc_V_ovflw: w_acc_V_ovflw+ w_leak;
   assign w_acc_V_leak_ovflw = (w_acc_V_leak[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH]==1'b0 && w_acc_V_leak[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1]==1'b1)? {2'b00,{`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1{1'b1}} }: 
                               (w_acc_V_leak[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH]==1'b1 && w_acc_V_leak[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1]==1'b0)? {2'b11,{`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1{1'b0}} }: w_acc_V_leak;
   assign w_acc_V = w_acc_V_leak_ovflw[`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0];

   assign w_spike          = (i_State == `ST_FIRE && r_acc_V >= w_threshold)? 1'b1:1'b0;
   assign w_leak_en        = (i_State == `ST_LEAK)? 1'b1:1'b0;
   assign w_threshold      = `LIF_THRESHOLD;
   assign w_leak           = `LIF_INV_LEAK;
   ////////////////////////////////////////////////////////////////////////////////
   // Seq. processes
   ////////////////////////////////////////////////////////////////////////////////
   always @ (posedge clk `__RST_SENS__) begin
      if (~rst_n)
        r_acc_V = `LIF_RESET_V;
      else begin
         if (w_spike)
           r_acc_V = `LIF_RESET_V;
         else if (w_leak_en | i_svalid)
           r_acc_V = w_acc_V;
      end
   end
   ////////////////////////////////////////////////////////////////////////////////
   // Output registers: for timing check only, please disable if you dont need
   ////////////////////////////////////////////////////////////////////////////////
   generate 
      if (OUTPUT_REG == 1) begin : OUTPUTREG
	 reg [`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] or_V;
	 reg [`LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH-1:0] or_spike;
	 always @ (posedge clk `__RST_SENS__) begin
            if (~rst_n) begin
               or_V = `LIF_RESET_V;
               or_spike = 1'b0;
            end else begin
               or_V = r_acc_V;
               or_spike = w_spike;
            end
	 end
	 assign o_V = or_V;
	 assign o_spike = or_spike;
      end else begin  : NO_OUTPUTREG
	 assign o_V = r_acc_V;
	 assign o_spike = w_spike;
      end
   endgenerate
   // `PRAGMA_SYN_OFF
   // always @(posedge clk) begin
   //     if (r_acc_V > 20 && w_leak_en == 1'b1)
   //         $display("Module: %m, time %d", $time); 
   // end
   // `PRAGMA_SYN_ON
endmodule // LIF_neuron
