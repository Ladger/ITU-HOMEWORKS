`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Berk Özcan 150220107 
// Ayberk Gürses 150220055
//
// BLG22E Assignment 1 - Part 2b
// Register File
//////////////////////////////////////////////////////////////////////////////////

module RegisterFile(
    input [15:0] I,
    input [2:0] OutASel,
    input [2:0] OutBSel,
    input [2:0] FunSel,
    input [3:0] RegSel,
    input [3:0] ScrSel,
    input Clock,
    output reg [15:0] OutA,
    output reg [15:0] OutB
    );
    
    wire ER1,ER2,ER3,ER4,ES1,ES2,ES3,ES4;
    
    wire [15:0] QR1;
    wire [15:0] QR2;
    wire [15:0] QR3;
    wire [15:0] QR4;
    
    wire [15:0] QS1;
    wire [15:0] QS2;
    wire [15:0] QS3;
    wire [15:0] QS4;
    
    assign {ER1,ER2,ER3,ER4} = ~{RegSel};
    assign {ES1,ES2,ES3,ES4} = ~{ScrSel};
    
    Register R1(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ER1), .Q(QR1));
    Register R2(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ER2), .Q(QR2));
    Register R3(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ER3), .Q(QR3));
    Register R4(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ER4), .Q(QR4));
    
    Register S1(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ES1), .Q(QS1));
    Register S2(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ES2), .Q(QS2));
    Register S3(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ES3), .Q(QS3));
    Register S4(.I(I), .FunSel(FunSel), .Clock(Clock), .E(ES4), .Q(QS4));
    
    
    always @(*)
    begin
        case(OutASel)
            3'b000: OutA <= QR1;
            3'b001: OutA <= QR2;
            3'b010: OutA <= QR3;
            3'b011: OutA <= QR4;
            3'b100: OutA <= QS1;
            3'b101: OutA <= QS2;
            3'b110: OutA <= QS3;
            3'b111: OutA <= QS4;
        endcase
        case(OutBSel)
            3'b000: OutB <= QR1;
            3'b001: OutB <= QR2;
            3'b010: OutB <= QR3;
            3'b011: OutB <= QR4;
            3'b100: OutB <= QS1;
            3'b101: OutB <= QS2;
            3'b110: OutB <= QS3;
            3'b111: OutB <= QS4;
        endcase
    end
endmodule
