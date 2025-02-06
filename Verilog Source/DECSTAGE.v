`include "Register_File.v"

module decode (
    input  clk, reset, RFwen, RFsel_write, RFsel_B,
    input [31:0] instr, ALU_out, MEM_out,
    output [31:0] immed, RF_A, RF_B
);
    wire [4:0] MUX1out;
    wire [31:0] MUX2out;
    assign MUX1out = (RFsel_B==1'b0) ? instr[15:11] : instr[20:16]; //0 for rt & 1 for rd
    assign MUX2out = (RFsel_write==1'b0) ? ALU_out : MEM_out; //0 for ALU_out & 1 for MEM_out
    
    register_file RF(.ard1(instr[25:21]), .ard2(MUX1out), .awr(instr[20:16]), .we(RFwen), .clk(clk), .reset(reset), .din(MUX2out), .dout1(RF_A), .dout2(RF_B));

    assign immed = ((&instr[31:26]==1'b1) || (|instr[31:27]==1'b0)) ? {{16{instr[15]}}, instr[15:0]} << 2 : // if opcode = 111111 or 00000_ (aka b, beq, bne) SignExtend(Imm)<<2
                   (instr[31:26] == 6'b111001) ? -instr[15:0]<<16 : //negative imm<<16 for lui (- for better handling by ALU)
                   (instr[31:27] == 5'b11001_) ? {{16{1'b0}}, instr[15:0]} : // ZeroFill(Immediate) for andi/ori which only differ on LSB of opcode
                   {{16{instr[15]}}, instr[15:0]};  // SignExtend(Immediate) for the rest

endmodule