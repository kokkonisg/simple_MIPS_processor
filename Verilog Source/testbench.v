`timescale 1ns/1ns
`include "PROCESSOR.v"

module testbench;
reg clk=1;
always #1 clk = ~clk;
reg reset = 1;

//for waveforms
wire [3:0] func = cpu.ctrl.func; //ALU function
wire [8:0] state = cpu.ctrl.curr_state; //the current state of the fsm
wire 	
	PCen = cpu.ctrl.PC_en, //Programm Counter: enable
	PCsel = cpu.ctrl.PC_sel, //Program Counter: MUX select, 0 for +4 & 1 for +Imm
	MEMen = cpu.ctrl.MEMwr_en, //Memory: RAM's write enable
	RFselwr = cpu.ctrl.RFsel_wr, //Register File: MUX select for input data, 0 for ALU's & 1 for MEM's output
	RFselB = cpu.ctrl.RFsel_B, //Register File: MUX select for 2nd address, 0 for $rt & 1 for $rd 
	RFen = cpu.ctrl.RFwr_en, //Register File: write enable
	ALUsel = cpu.ctrl.ALUsel_B, //ALU: MUX select for 2nd input, 0 for RF's 2nd output & 1 for Immediate
	zero = cpu.dpath.zero; //ALU: is 1 if ALU's inputs are equal, used for beq/bne
wire [31:0] 
	instr = cpu.dpath.instr, //Instruction
	immed = cpu.dpath.immed, //Immediate
	ALUout = cpu.dpath.ALU_out, //ALU: output
	MEMout= cpu.dpath.MEM_out, //MEM: output
	A = cpu.dpath.RF_A, //Register File: value stored in register driven by 1st address
	B = cpu.dpath.RF_B; //Register File: value stored in register driven by 2nd address
wire [31:0] counter = cpu.dpath.if_mod.pc_out; //PC: the current value of the programm counter


initial $dumpfile("testbench.vcd");
initial $dumpvars(0, testbench);

processor cpu(clk, reset);
// datapath dpath(clk, reset, en, PCsel, RFwrsel, RFsel, RFwr, ALUsel, MEMwr, func, zero ,instr, immed, ALU_out, MEM_out, RF_A, RF_B);
// control ctrl(clk, zero, instr, en, PCsel, MEMwr, RFwrsel, RFsel, RFwr, ALUsel, func, state);

initial begin
    $readmemb("assembly_rom.data", cpu.dpath.if_mod.rom_mod.ROM);
	@(negedge clk);
	reset = 0;
    // # 150;
	// @(posedge clk);
	// reset = 1;
	// @(negedge clk);
	// reset = 0;
	# 300; 
    $finish;
end

integer j=0;
always@(clk) begin
    //display values of all registers at the end of the simultaion
        if($time==299) 
            for(j=0;j<32/4;j=j+1) begin
                $write("Register %2d has: %3d  |", j, $signed(cpu.dpath.dec_mod.RF.reg_dout[32*j+:32]));
                $write("  Register %2d has: %3d  |", (8+j), $signed(cpu.dpath.dec_mod.RF.reg_dout[32*(8+j)+:32]));
                $write("  Register %2d has: %3d  |", (16+j), $signed(cpu.dpath.dec_mod.RF.reg_dout[32*(16+j)+:32]));
                $display("  Register %2d has: %3d", (24+j), $signed(cpu.dpath.dec_mod.RF.reg_dout[32*(24+j)+:32]));
            end
end

endmodule