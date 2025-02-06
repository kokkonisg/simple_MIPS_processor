`include "decoder.v"

module register (
    input clk, reset, 
    input we, //write enable, initialize
    input [31:0] din,
    output reg [31:0] dout 
    );
    
    always @(negedge clk, posedge reset) begin
        if (reset)
            dout <= 32'b0;
        else
            dout <= we ? din : dout;
    end

endmodule


module register_file (
    input [4:0] ard1, ard2, awr, 
    input we, clk, reset, 
    input [31:0] din,
    output reg [31:0] dout1, dout2
    );

    wire [31:0] wren_addr; //an array for the decoders output, aka to which register is the awr showing 
    wire [1023:0] reg_dout; //an array which stores the outputs of the individual registers
    
    decoder5to32 decoder(.A(awr), .F(wren_addr)); 

    //reg0 needs to allways store 0
    assign reg_dout[0 +: 32] = 32'b0;
    
    //generating 32 registers, they output in an array so the MUX can choose and the enable is the logic and of global wr. en. and the write address  
    genvar i;
    generate
        for (i=1; i<32; i=i+1) begin: Register_Array_Init
            register reg_arr (clk, reset, (we & wren_addr[i]), din, reg_dout[32*i +: 32]);
        end
    endgenerate 
    
    always @(*) begin
        dout1 = 32'b0;
        dout2 = 32'b0;
        for (integer i=0; i<32; i=i+1) begin
            if (ard1 == i) dout1 = reg_dout[32*i +: 32];
            if (ard2 == i) dout2 = reg_dout[32*i +: 32];
        end
    end

endmodule