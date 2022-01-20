`include "decoder.v"

module register (
    input clk, 
    input we, in, //write enable, initialize
    input [31:0] din,
    output reg [31:0] dout 
    );
    
    initial begin
        if(in) //so we can choose wich reg to initialize. In this case reg0 will be initialized with 0
            dout <= 0;
    end
    
    always @(negedge clk)
        dout <= we ? din : dout;

endmodule


module register_file (
    input [4:0] ard1, ard2, awr,
    input we, clk,
    input [31:0] din,
    output [31:0] dout1, dout2
    );

    wire [31:0] wren_addr; //an array for the decoders output, aka to which register is the awr showing 
    wire [1023:0] reg_dout; //an array which stores the outputs of the individual registers
    
    decoder5to32 decoder(.A(awr), .F(wren_addr)); 

    //generating 32 registers, they output in an array so the MUX can choose and the enable is the logic and of global wr. en. and the write address  
    genvar i;
    generate
        for (i=1; i<32; i=i+1) begin: Registers
            register reg_arr (clk, (we & wren_addr[i]), 1'b0, din, reg_dout[32*i +: 32]);
        end
    endgenerate 
    //reg0 needs to allways store 0
    register reg0(clk, (we & wren_addr[0]), 1'b1, {32'b0}, reg_dout[0 +: 32]);   

    output_MUX MUX1(ard1, reg_dout, dout1);
    output_MUX MUX2(ard2, reg_dout, dout2);
    
    //display values of all registers at the end of the simultaion
    integer j=0;
    always @(clk)
        if($time==299) 
            for(j=0;j<32/4;j=j+1) begin
                $write("Register %2d has: %3d  |", j, $signed(reg_dout[32*j+:32]));
                $write("  Register %2d has: %3d  |", (8+j), $signed(reg_dout[32*(8+j)+:32]));
                $write("  Register %2d has: %3d  |", (16+j), $signed(reg_dout[32*(16+j)+:32]));
                $display("  Register %2d has: %3d", (24+j), $signed(reg_dout[32*(24+j)+:32]));
            end
endmodule

module output_MUX (
    input [4:0] sel,
    input [1023:0] regout,
    output [31:0] dout
);
    assign dout = (sel==5'd0)  ? regout[31:0]    :                   
                  (sel==5'd1)  ? regout[63:32]   :     
                  (sel==5'd2)  ? regout[95:64]   :     
                  (sel==5'd3)  ? regout[127:96]  :   
                  (sel==5'd4)  ? regout[159:128] : 
                  (sel==5'd5)  ? regout[191:160] : 
                  (sel==5'd6)  ? regout[223:192] : 
                  (sel==5'd7)  ? regout[255:224] : 
                  (sel==5'd8)  ? regout[287:256] : 
                  (sel==5'd9)  ? regout[319:288] : 
                  (sel==5'd10) ? regout[351:320] :
                  (sel==5'd11) ? regout[383:352] :
                  (sel==5'd12) ? regout[415:384] :
                  (sel==5'd13) ? regout[447:416] :
                  (sel==5'd14) ? regout[479:448] :
                  (sel==5'd15) ? regout[511:480] :
                  (sel==5'd16) ? regout[543:512] :
                  (sel==5'd17) ? regout[575:544] :
                  (sel==5'd18) ? regout[607:576] :
                  (sel==5'd19) ? regout[639:608] :
                  (sel==5'd20) ? regout[671:640] :
                  (sel==5'd21) ? regout[703:672] :
                  (sel==5'd22) ? regout[735:704] :
                  (sel==5'd23) ? regout[767:736] :
                  (sel==5'd24) ? regout[799:768] :
                  (sel==5'd25) ? regout[831:800] :
                  (sel==5'd26) ? regout[863:832] :
                  (sel==5'd27) ? regout[895:864] :
                  (sel==5'd28) ? regout[927:896] :
                  (sel==5'd29) ? regout[959:928] :
                  (sel==5'd30) ? regout[991:960] :
                  (sel==5'd31) ? regout[1023:992] :
                  32'dX;
endmodule