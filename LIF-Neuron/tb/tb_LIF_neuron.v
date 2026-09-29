`timescale 1ns/1ps

module tb_LIF_neuron;

   parameter WEIGHT_WIDTH           = 8;
   parameter LIF_NEURON_OVRFL_WIDTH = 8;
   parameter STATE_WIDTH            = 3; // From common.v

   // State definitions from common.v
   localparam ST_IDLE          = 3'd0;
   localparam ST_DOWNLD_SPIKE  = 3'd1;
   localparam ST_GENSPK_A_COM  = 3'd2;
   localparam ST_LEAK          = 3'd3;
   localparam ST_FIRE          = 3'd4;
   localparam ST_UPLD_SPIKE    = 3'd5;

   // DUT Signals
   reg                                clk;
   reg                                rst_n;
   reg  [WEIGHT_WIDTH-1:0]            i_wspike;
   reg                                i_svalid;
   reg  [STATE_WIDTH-1:0]             i_State;
   wire [LIF_NEURON_OVRFL_WIDTH+WEIGHT_WIDTH-1:0] o_V;
   wire                               o_spike;
   wire                               TBD;

   // Instantiate the Gate-Level Netlist DUT
   LIF_neuron dut (
      .clk      (clk),
      .rst_n    (rst_n),
      .i_wspike (i_wspike),
      .i_svalid (i_svalid),
      .i_State  (i_State),
      .o_V      (o_V),
      .o_spike  (o_spike),
      .TBD      (TBD)
   );

   // Clock generation: 10 ns period (100 MHz)
   always #5 clk = ~clk;

   // Spike and cycle counters
   integer spike_count;
   integer cycle_count;
   integer i;

   // Count output firing events
   always @(posedge clk) begin
      if (rst_n && o_spike) begin
         spike_count = spike_count + 1;
      end
   end

   // Simulation Process
   initial begin
      clk         = 0;
      rst_n       = 0;
      i_wspike    = 8'h00;
      i_svalid    = 1'b0;
      i_State     = ST_IDLE;
      spike_count = 0;

      // 1. Reset DUT cleanly (50 ns)
      #50;
      rst_n = 1;
      @(posedge clk);
      #1;

      // 2. Open activity dump file AFTER reset is deasserted
      $dumpfile("activity.vcd");
      $dumpvars(0, tb_LIF_neuron.dut);

      // 3. Execution Modes
      if ($test$plusargs("MODE_IDLE")) begin
         // =============================================================
         // MODE 1: NO SPIKES (IDLE / QUIESCENT & BUS TOGGLING)
         // =============================================================
         $display("---------------------------------------------------------");
         $display(">>> RUNNING MODE: NO SPIKES (IDLE) <<<");
         $display("---------------------------------------------------------");
         i_svalid = 1'b0;
         i_State  = ST_IDLE;

         // Phase A: Complete quiescence (all 0s) for 100 cycles
         i_wspike = 8'h00;
         repeat (100) @(posedge clk);

         // Phase B: Bus toggling between all-0s and all-1s while invalid
         // (Simulates shared bus toggles when neuron is not selected)
         repeat (100) begin
            @(posedge clk);
            i_wspike = 8'hFF; // all 1s
            @(posedge clk);
            i_wspike = 8'h00; // all 0s
         end

      end else begin
         // =============================================================
         // MODE 2: ACTIVE SPIKES (INTEGRATE -> FIRE -> RESET)
         // =============================================================
         $display("---------------------------------------------------------");
         $display(">>> RUNNING MODE: ACTIVE SPIKES <<<");
         $display("---------------------------------------------------------");

         // Loop 50 rounds: each round integrates weights until firing occurs
         repeat (50) begin
            
            // Sub-phase 1: Excitatory spike integration with all-1s transition
            // 4 spikes of +32 = 128 (reaches threshold)
            repeat (4) begin
               @(posedge clk);
               i_State  = ST_DOWNLD_SPIKE;
               i_svalid = 1'b1;
               i_wspike = 8'd32;

               @(posedge clk);
               i_State  = ST_LEAK;
               i_svalid = 1'b0;
               i_wspike = 8'h00; // Return to 0
            end

            // Sub-phase 2: Fire check (fires because V >= 128)
            @(posedge clk);
            i_State  = ST_FIRE;
            i_svalid = 1'b0;

            // Sub-phase 3: Toggle test (All 1s test vector)
            @(posedge clk);
            i_State  = ST_DOWNLD_SPIKE;
            i_svalid = 1'b1;
            i_wspike = 8'h7F; // Maximum positive 8-bit signed value (+127)

            @(posedge clk);
            i_State  = ST_IDLE;
            i_svalid = 1'b0;
            i_wspike = 8'h80; // Negative/inverted test pattern (-128)

            @(posedge clk);
            i_State  = ST_IDLE;
            i_wspike = 8'h00; // Back to all zeros
         end
      end

      // 4. Conclude measurement window
      @(posedge clk);
      $dumpoff;
      $display("---------------------------------------------------------");
      $display(">>> SIMULATION FINISHED <<<");
      $display("Total output spikes fired: %0d", spike_count);
      $display("Simulation End Time: %0t ps", $time);
      $display("---------------------------------------------------------");
      $finish;
   end

endmodule