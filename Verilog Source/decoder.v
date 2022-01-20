// module decoder1to2 (
//     input A,
//     output [1:0] F
// );

//     assign F[1] = A;   
//     assign F[0] = ~A;   

// endmodule

// module decoder2to4 (
//     input [1:0] A,
//     output [3:0] F
// );
//     wire [3:0] W;

//     decoder1to2 d0(.A(A[1]), .F(W[3:2]));
//     decoder1to2 d1(.A(A[0]), .F(W[1:0]));
    
//     assign F[3] = W[3] & W[1];
//     assign F[2] = W[3] & W[0];
//     assign F[1] = W[2] & W[1];
//     assign F[0] = W[2] & W[0];
// endmodule

// module decoder3to8 (
//     input [2:0] A,
//     output [7:0] F
// );
//     wire [5:0] W;
    
//     decoder2to4 d0(.A(A[2:1]), .F(W[5:2]));
//     decoder1to2 d1(.A(A[0]), .F(W[1:0]));

//     assign F[7] = W[5] & W[1];
//     assign F[6] = W[5] & W[0];
//     assign F[5] = W[4] & W[1];
//     assign F[4] = W[4] & W[0];
//     assign F[3] = W[3] & W[1];
//     assign F[2] = W[3] & W[0];
//     assign F[1] = W[2] & W[1];
//     assign F[0] = W[2] & W[0];

// endmodule

// module decoder5to32 (
//     input [4:0] A,
//     output [31:0] F
// );

//     wire [11:0] W;
    
//     decoder3to8 d0(.A(A[4:2]), .F(W[11:4]));
//     decoder2to4 d1(.A(A[1:0]), .F(W[3:0]));

//     assign F[31] = W[11] & W[3];
//     assign F[30] = W[11] & W[2];
//     assign F[29] = W[11] & W[1];
//     assign F[28] = W[11] & W[0];
//     assign F[27] = W[10] & W[3];
//     assign F[26] = W[10] & W[2];
//     assign F[25] = W[10] & W[1];
//     assign F[24] = W[10] & W[0];
//     assign F[23] = W[9] & W[3];
//     assign F[22] = W[9] & W[2];
//     assign F[21] = W[9] & W[1];
//     assign F[20] = W[9] & W[0];
//     assign F[19] = W[8] & W[3];
//     assign F[18] = W[8] & W[2];
//     assign F[17] = W[8] & W[1];
//     assign F[16] = W[8] & W[0];
//     assign F[15] = W[7] & W[3];
//     assign F[14] = W[7] & W[2];
//     assign F[13] = W[7] & W[1];
//     assign F[12] = W[7] & W[0];
//     assign F[11] = W[6] & W[3];
//     assign F[10] = W[6] & W[2];
//     assign F[9] = W[6] & W[1];
//     assign F[8] = W[6] & W[0];
//     assign F[7] = W[5] & W[3];
//     assign F[6] = W[5] & W[2];
//     assign F[5] = W[5] & W[1];
//     assign F[4] = W[5] & W[0];
//     assign F[3] = W[4] & W[3];
//     assign F[2] = W[4] & W[2];
//     assign F[1] = W[4] & W[1];
//     assign F[0] = W[4] & W[0];

// endmodule

//--------------------------------------------//

//generated with simple python script:
// for i in range(32):
//    print("5'd", i, ": F <= 32'd", 2**i)
module decoder5to32 (
    input [4:0] A,
    output reg [31:0] F
    );

    always @* begin
        case(A)
            5'd0  : F <= 32'd1;
            5'd1  : F <= 32'd2;
            5'd2  : F <= 32'd4;
            5'd3  : F <= 32'd8;
            5'd4  : F <= 32'd16;
            5'd5  : F <= 32'd32;
            5'd6  : F <= 32'd64;
            5'd7  : F <= 32'd128;
            5'd8  : F <= 32'd256;
            5'd9  : F <= 32'd512;
            5'd10 : F <= 32'd1024;
            5'd11 : F <= 32'd2048;
            5'd12 : F <= 32'd4096;
            5'd13 : F <= 32'd8192;
            5'd14 : F <= 32'd16384;
            5'd15 : F <= 32'd32768;
            5'd16 : F <= 32'd65536;
            5'd17 : F <= 32'd131072;
            5'd18 : F <= 32'd262144;
            5'd19 : F <= 32'd524288;
            5'd20 : F <= 32'd1048576;
            5'd21 : F <= 32'd2097152;
            5'd22 : F <= 32'd4194304;
            5'd23 : F <= 32'd8388608;
            5'd24 : F <= 32'd16777216;
            5'd25 : F <= 32'd33554432;
            5'd26 : F <= 32'd67108864;
            5'd27 : F <= 32'd134217728;
            5'd28 : F <= 32'd268435456;
            5'd29 : F <= 32'd536870912;
            5'd30 : F <= 32'd1073741824;
            5'd31 : F <= 32'd2147483648;
            default : F = 32'dX;
        endcase
    end
endmodule