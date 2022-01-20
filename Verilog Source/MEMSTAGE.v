module RAM (
    input clk,
    input we,
    input [9:0] addr,
    input [31:0] din,
    output reg [31:0] dout
);
    reg [31:0] RAM [1023:0];

    always @(negedge clk) begin
        if(we)
            RAM[addr] = din;
        else
            dout = RAM[addr];
    end
endmodule

module MEMSTAGE (
    input clk,
    input MEM_we,
    input [31:0] ALU_MEM_addr,
    input [31:0] MEM_datain,
    output [31:0] MEM_dout
);
    RAM mem(.clk(clk), .we(MEM_we), .addr(ALU_MEM_addr[11:2]), .din(MEM_datain), .dout(MEM_dout));

endmodule