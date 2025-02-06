module control (
    input clk, reset, zero,
    input [31:0] instr,
    output reg PC_en, PC_sel, MEMwr_en, RFsel_wr, RFsel_B, RFwr_en, ALUsel_B,
    output reg [3:0] func
);

    parameter [8:0]
        i_fetch     = 9'b0_0000_0001,
        decode_rr   = 9'b0_0000_0010,
        mem_addr    = 9'b0_0000_0100,
        mem_wr      = 9'b0_0000_1000,
        mem_rd      = 9'b0_0001_0000,
        ld_wb       = 9'b0_0010_0000,
        alu_exec    = 9'b0_0100_0000,
        alu_wb      = 9'b0_1000_0000,
        branch      = 9'b1_0000_0000;

    reg [8:0] curr_state, next_state;

    wire [5:0] opcode = instr[31:26]; //assignment for aesthetic purposes
    
    //changing to next state
    always @(posedge clk, posedge reset) begin
        if (reset)
            curr_state <= i_fetch;
        else
            curr_state <= next_state;
    end

    //selecting next state
    always @(*) begin
        //initializing next state to i_fetch
        next_state = i_fetch;
        case (curr_state)
            i_fetch: next_state = decode_rr;
            decode_rr: begin
                if (|instr == 1'b0) //nop
                    next_state = i_fetch;
                else if (opcode[5]==1'b0 && opcode[1:0]==2'b11) //lw, sw
                    next_state = mem_addr;
                else if (opcode[5]==1'b1 && opcode!=6'b111111) //add, addi, ...
                    next_state = alu_exec;
                else if (opcode==6'b111111 || |opcode[5:1]==1'b0) //b, beq, bne
                    next_state = branch;
                else
                    next_state = i_fetch;    
            end
            mem_addr: begin
                if (opcode==6'b000111 || opcode==6'b011111)
                    next_state = mem_wr;
                else
                    next_state = mem_rd;
            end
            mem_wr: next_state = i_fetch;
            mem_rd: next_state = ld_wb;
            ld_wb: next_state = i_fetch;
            alu_exec: next_state = alu_wb;
            alu_wb: next_state = i_fetch;
            branch: next_state = i_fetch;
            default: next_state = i_fetch;
        endcase
    end

    //outputs based on the current state
    always @(*) begin
        //initializing all outputs to 0
        PC_en = 0;
        PC_sel = 0;
        MEMwr_en = 0;
        RFsel_wr = 0;
        RFsel_B = 0;
        RFwr_en = 0;
        ALUsel_B = 0;
        func = 4'b0000;
        //setting outputs based on the current state
        case (curr_state)
            i_fetch: begin
                RFsel_B = 1;
                func = 4'b0001; //in ALU subtract values to check if they're equal
                ALUsel_B = 0; //in ALU select RF's output for input B
                if (opcode==6'b111111 || |opcode[5:1]==1'b0) //in case of branch
                    PC_sel = opcode[5] | opcode[0]^zero; //(if 1) select to increment by immediate, (if 0) or not depending on condition
                else
                    PC_sel = 0;
                PC_en = 1;
            end
            decode_rr: begin
    /*nop*/     if (opcode[5]==1'b0 && opcode[1:0]==2'b11) begin//lw, sw
                    RFsel_B = 1;
                    func = 4'b0000;
                    ALUsel_B = 1; //in ALU select immediate for input B
                end                 
                else if (opcode[5]==1'b1 && opcode!=6'b111111) begin//add, addi, ...
                    if (opcode[4] == 1'b0) begin
                        RFsel_B = 0; //in RF select $rt for input B
                        func = instr[3:0];
                    end
                    else begin
                        RFsel_B = 1; //in RF select $rd for input B
                        func = {1'b0, opcode[2:0]};
                    end
                    RFsel_wr = 0; //in RF select ALU output for data in
                end
                else if (opcode==6'b111111 || |opcode[5:1]==1'b0) begin//b, beq, bne
                    RFsel_B = 1;
                    func = 4'b0001; //in ALU subtract values to check if they're equal
                    ALUsel_B = 0; //in ALU select RF's output for input B
                    PC_sel = opcode[5] | opcode[0]^zero; //in PC, (if 1) select to increment by immediate, (if 0) or not depending on condition
                end
            end
            mem_addr: begin
                RFsel_B = 1;
                func = 4'b0000;
                ALUsel_B = 1; //in ALU select immediate for input B
            end
            mem_wr: begin
                RFsel_B = 1;
                func = 4'b0000;
                ALUsel_B = 1; //in ALU select immediate for input B
                MEMwr_en = 1; //write enable MEM
            end
            mem_rd: begin
                RFsel_B = 1;
                func = 4'b0000;
                ALUsel_B = 1; //in ALU select immediate for input B
                RFsel_wr = 1; //in RF select MEM output for data in
            end
            ld_wb: begin
                func = 4'b0000;
                ALUsel_B = 1; //in ALU select immediate for input B
                RFsel_wr = 1; //in RF select MEM output for data in
                RFwr_en = 1; 
            end
            alu_exec: begin
                if (opcode[4] == 1'b0) begin
                    RFsel_B = 0; //in RF select $rt for input B
                    func = instr[3:0];
                    ALUsel_B = 0; //in ALU select RF's output for input B
                end
                else begin
                    RFsel_B = 1; //in RF select $rd for input B
                    func = {1'b0, opcode[2:0]};
                    ALUsel_B = 1; //in ALU select immediate for input B
                end
                RFsel_wr = 0; //in RF select ALU output for data in
            end
            alu_wb: begin
                if (opcode[4] == 1'b0) begin
                    RFsel_B = 0; //in RF select $rt for input B
                    func = instr[3:0];
                    ALUsel_B = 0; //in ALU select RF's output for input B
                end
                else begin
                    RFsel_B = 1; //in RF select $rd for input B
                    func = {1'b0, opcode[2:0]};
                    ALUsel_B = 1; //in ALU select immediate for input B
                end
                RFsel_wr = 0; //in RF select ALU output for data in
                RFwr_en = 1; //write enable RF                
            end
            branch: begin
                RFsel_B = 1;
                func = 4'b0001; //in ALU subtract values to check if they're equal
                ALUsel_B = 0; //in ALU select RF's output for input B
                PC_sel = opcode[5] | opcode[0]^zero; //in PC, (if 1) select to increment by immediate, (if 0) or not depending on condition
            end     
        endcase
    end

endmodule