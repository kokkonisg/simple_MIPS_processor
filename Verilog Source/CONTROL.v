module control (
    input clk, reset, zero,
    input [31:0] instr,
    output reg PC_en, PC_sel, MEMwr_en, RFsel_wr, RFsel_B, RFwr_en, ALUsel_B,
    output reg [3:0] func
);

    parameter [8:0]
        i_fetch     = 9'b000000001,
        decode_rr   = 9'b000000010,
        mem_addr    = 9'b000000100,
        mem_wr      = 9'b000001000,
        mem_rd      = 9'b000010000,
        ld_wb       = 9'b000100000,
        alu_exec    = 9'b001000000,
        alu_wb      = 9'b010000000,
        branch      = 9'b100000000;

    reg [8:0] curr_state, next_state;

    wire [5:0] opcode = instr[31:26]; //assignment for aesthetic purposes
    
    //changing to next state
    always @(posedge clk, posedge reset) begin
        if (reset)
            curr_state <= i_fetch;
        curr_state <= next_state;
    end

    //selecting next state
    always @(curr_state, instr) begin
        case (curr_state)
            i_fetch: next_state <= decode_rr;
            decode_rr: begin
                if (|instr == 1'b0)
                    next_state <= i_fetch;
                else if (opcode[5]==1'b0 && opcode[1:0]==2'b11)
                    next_state <= mem_addr;
                else if (opcode[5]==1'b1 && opcode!=6'b111111)
                    next_state <= alu_exec;
                else if (opcode==6'b111111 || |opcode[5:1]==1'b0)
                    next_state <= branch;
                // else
                //     next_state <= i_fetch;    
            end
            mem_addr: begin
                if (opcode==6'b000111 || opcode==6'b011111)
                    next_state <= mem_wr;
                else
                    next_state <= mem_rd;
            end
            mem_wr: next_state <= i_fetch;
            mem_rd: next_state <= ld_wb;
            ld_wb: next_state <= i_fetch;
            alu_exec: next_state <= alu_wb;
            alu_wb: next_state <= i_fetch;
            branch: next_state <= i_fetch;
            default: next_state <= i_fetch;
        endcase
    end

    //outputs based on the current state
    always @(curr_state, instr) begin
        case (curr_state)
            i_fetch: begin
                PC_en <= 0; 
                RFwr_en <= 0;
            end
            decode_rr: begin
                if(|instr==0) begin
                    PC_sel <= 0;
                    PC_en <= 1;
                end
                if (opcode[5:4]==2'b10)
                    RFsel_B <= 0; //in RF select $rt for input B
                else
                    RFsel_B <= 1; //in RF select $rd for input B
            end
            mem_addr: begin
                if (opcode==6'b000111 || opcode==6'b011111)
                    MEMwr_en <= 1;
                func <= 4'b0000;
                ALUsel_B <= 1; //in ALU select immediate for input B
            end
            mem_wr: begin
                MEMwr_en <= 0; //write enable MEM
                PC_en <= 1;
                PC_sel <= 0;
            end
            mem_rd: begin
                RFsel_wr <= 1; //in RF select MEM output for data in
            end
            ld_wb: begin
                RFwr_en <= 1; //write enable RF
                PC_en <= 1;
                PC_sel <= 0;
            end
            alu_exec: begin
                if (opcode[5:4] == 2'b10) begin
                    func <= instr[3:0];
                    ALUsel_B <= 0; //in ALU select RF's output for input B
                end
                else begin
                    func <= {1'b0, opcode[2:0]};
                    ALUsel_B <= 1; //in ALU select immediate for input B
                end
                RFsel_wr <= 0; //in RF select ALU output for data in
            end
            alu_wb: begin
                RFwr_en <= 1; //write enable RF
                PC_en <= 1;
                PC_sel <= 0;
            end
            branch: begin
                PC_en <= 1;
                //$display("State %b, Opcode %b", curr_state, opcode);
                func <= 4'b0001; //in ALU subtract values to check if they're equal
                ALUsel_B <= 0; //in ALU select RF's output for input B
                PC_sel <= opcode[5] | opcode[0]^zero; //in PC, (if 1) select to incremmend by immediate, (if 0) or not depending on condition
            end     //this ^ is 1 for b this ^ is 0 for beq and 1 for bne, with xor we achieve the result we desire
        endcase
    end

endmodule