`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Berk Özcan 150220107 
// Ayberk Gürses 150220055
//
// BLG22E Assignment 1 - Part 2c
// Adress Register File
//////////////////////////////////////////////////////////////////////////////////

module AddressRegisterFile(
    input [15:0] I,
    input [1:0] OutCSel,
    input [1:0] OutDSel,
    input [2:0] FunSel,
    input [2:0] RegSel,
    input Clock,
    output reg [15:0] OutC,
    output reg [15:0] OutD
    );
    
    wire E_PC, E_AR, E_SP;
    
    wire [15:0] Q_PC;
    wire [15:0] Q_AR;
    wire [15:0] Q_SP;
    
    assign {E_PC,E_AR,E_SP} = ~RegSel;
    
    Register PC(.I(I), .FunSel(FunSel), .Clock(Clock), .E(E_PC), .Q(Q_PC));
    Register AR(.I(I), .FunSel(FunSel), .Clock(Clock), .E(E_AR), .Q(Q_AR));
    Register SP(.I(I), .FunSel(FunSel), .Clock(Clock), .E(E_SP), .Q(Q_SP));
    
    always @(*)
    begin
        case (OutCSel)
            2'b00: OutC <= Q_PC;
            2'b01: OutC <= Q_PC;
            2'b10: OutC <= Q_AR;
            2'b11: OutC <= Q_SP;
        endcase
        case (OutDSel)
            2'b00: OutD <= Q_PC;
            2'b01: OutD <= Q_PC;
            2'b10: OutD <= Q_AR;
            2'b11: OutD <= Q_SP;
        endcase
    end
endmodule
