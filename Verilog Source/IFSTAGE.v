module ROM(
    input clk,
    input [9:0] addr,
    output reg [31:0] dout
    );

    reg [31:0] ROM [0:1023];

    //read data from .data file
    initial begin
     $readmemb("assembly_rom.data", ROM); 
    end
    
    //output data on given address
    always @(negedge clk) begin
        dout <= ROM[addr];
    end
	 
endmodule

module PC (
    input clk, PC_en, reset,
    input [11:0] counter_in,
    output reg [11:0] counter_out
    );
    
    always @(posedge clk or posedge reset) begin
        if(reset)
            counter_out <= 0;
        else if(PC_en)
            counter_out <= counter_in;
    end
	
endmodule

module incr ( //incrementor +4
    input [11:0] counter_in,
    output [11:0] counter_out
    );

    assign counter_out = counter_in + 4;
    
endmodule

module incr_immed ( //incrementor +4 +immediate
    input [11:0] counter_in,
    input [31:0] immed,
    output [11:0] counter_out
    );

    assign counter_out = counter_in + immed;
endmodule

module MUX (
    input sel,
    input [11:0] counter, counter_immed,
    output [11:0] counter_out
    );

    assign counter_out = (sel == 1'b1) ? counter_immed : counter;
    
endmodule

module IF (
    input clk, reset, PC_en, select,
    input [31:0] immed,
    output [31:0] instr
);
    wire [11:0] mux_out, incr4, incrImm, pc_out;

    ROM rom_mod(.clk(clk), .addr(pc_out[11:2]), .dout(instr));
    PC pc_mod(.clk(clk), .reset(reset), .PC_en(PC_en), .counter_in(mux_out), .counter_out(pc_out));
    incr incr4_mod(.counter_in(pc_out), .counter_out(incr4));
    incr_immed incrImm_mod(.immed(immed), .counter_in(incr4), .counter_out(incrImm));
    MUX mux_mod(.sel(select), .counter(incr4), .counter_immed(incrImm), .counter_out(mux_out));
    
	 
endmodule