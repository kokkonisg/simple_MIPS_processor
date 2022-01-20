`include "DATAPATH.v"
`include "CONTROL.v"

module processor(
    input clk, reset
);
    wire [3:0] func;
    wire clk, reset, PCen, PCsel, RFwrsel, RFsel, RFwr, ALUsel, MEMwr;
    wire [31:0] instr, immed;
    wire zero;

    datapath dpath(clk, reset, PCen, PCsel, RFwrsel, RFsel, RFwr, ALUsel, MEMwr, func, zero ,instr, immed);
    control ctrl(clk, reset, zero, instr, PCen, PCsel, MEMwr, RFwrsel, RFsel, RFwr, ALUsel, func);
endmodule