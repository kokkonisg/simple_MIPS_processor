module ALU (
    output reg [31:0] out, //ALU's result
    output reg zero, //1 if 2 inputs are equal
    input [31:0] A, B, //the 2 inputs
    input [3:0] op //function code of the ALU
    );

    always @(*) begin 
        out = 32'b0;
        zero = 1'b0; 
        case (op)
            4'b0000:  out = A + B;
            4'b0001:  begin
                out = A - B;
                zero = ~|out;
                //(^)this way if a single bit is 1 the outult will be 1, so ~1=0
            end
            4'b0010:  out = A & B;
            4'b0011:  out = A | B;
            4'b0100:  out = ~A;
            4'b1000:  out = (A>>>1); //shifts the the right and keeps MSB 
            4'b1010:  out = (A>>1);
            4'b1001:  out = (A<<1);
            4'b1100:  out = (A<<1) + {{31{1'b0}}, A[31]};  //shifts to the left and keeps the prev MSB as the new LSB instead of 0
            4'b1101:  out = (A>>1) + {A[0], {31{1'b0}}}; //shifts to the right and keeps the prev LSB as the new MSB instead of 0
            default:
                if (op!=4'dX)
                    $display("Unknown func %4b", op); //for the values of func that do not exist here
        endcase
    end
    
endmodule //ALU

module ALUSTAGE (
    input [31:0] RF_A, RF_B, immed,
    input Bsel,
    input [3:0] func,
    output zero,
    output [31:0] ALU_out 
);
	 
	wire [31:0] MUXout = (Bsel == 1'b0) ? RF_B : immed; // 0 for RF's output & 1 for immediate
    ALU alu(.A(RF_A), .B(MUXout), .op(func), .out(ALU_out), .zero(zero));
    
    
endmodule