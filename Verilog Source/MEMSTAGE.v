module RAM (
    input clk, reset,
    input we,
    input [9:0] addr,
    input [31:0] din,
    output reg [31:0] dout
);
    reg [31:0] RAM [1023:0];

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < 1024; i = i + 1) begin
                RAM[i] <= 32'b0;
            end
        end else if (we) begin
            RAM[addr] <= din;
        end
    end

    always @(posedge clk) begin
        if (!we) begin
            dout <= RAM[addr];
        end
    end
endmodule

module MEMSTAGE (
    input clk, reset,
    input MEM_we,
    input [9:0] ALU_MEM_addr,
    input [31:0] MEM_datain,
    output [31:0] MEM_dout
);
    RAM mem(.clk(clk), .reset(reset), .we(MEM_we), .addr(ALU_MEM_addr), .din(MEM_datain), .dout(MEM_dout));

endmodule