`define LIF_WEIGHT_WIDTH        8
`define LIF_NEURON_OVRFL_WIDTH  8
`define LIF_RESET_V             8'd0
`define LIF_LEAK                10'd0
`define LIF_INV_LEAK            10'd0 //`LIF_LEAK*(-1)
`define LIF_THRESHOLD_WIDTH     `LIF_WEIGHT_WIDTH+`LIF_NEURON_OVRFL_WIDTH+1
`define LIF_THRESHOLD           128 //10'd21