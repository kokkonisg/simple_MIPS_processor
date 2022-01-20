`include "IFSTAGE.v"
`include "DECSTAGE.v"
`include "ALUSTAGE.v"
`include "MEMSTAGE.v"

module datapath (
    input clk, reset, en, PC_sel, RFsel_wr, RFsel_B, RFwr_en, ALUsel_B, MEMwr_en,
    input [3:0] func,
    output zero,
    output [31:0] instr, immed
);
    wire [31:0] ALU_out, MEM_out, RF_A, RF_B;
    wire [31:0] temp_memin, temp_memout; //in case of lb/sb edit values accordingly before passing them on
	assign temp_memin = (instr[31:26]==6'b000111) ? {{24{1'b0}}, RF_B[7:0]} : RF_B;
    assign temp_memout = (instr[31:26]==6'b000011) ? {{24{1'b0}}, MEM_out[7:0]} : MEM_out;

    IF if_mod(.clk(clk), .reset(reset), .PC_en(en), .select(PC_sel), .immed(immed), .instr(instr));
    decode dec_mod(.clk(clk), .RFsel_write(RFsel_wr), .RFsel_B(RFsel_B), .RFwen(RFwr_en), .instr(instr), .ALU_out(ALU_out), .MEM_out(temp_memout), .immed(immed), .RF_A(RF_A), .RF_B(RF_B));
    ALUSTAGE alu_mod(.immed(immed), .RF_A(RF_A), .RF_B(RF_B), .Bsel(ALUsel_B), .func(func), .ALU_out(ALU_out), .zero(zero));
    MEMSTAGE mem_mod(.clk(clk), .MEM_we(MEMwr_en), .ALU_MEM_addr(ALU_out), .MEM_datain(temp_memin), .MEM_dout(MEM_out));
        
    endmodule
