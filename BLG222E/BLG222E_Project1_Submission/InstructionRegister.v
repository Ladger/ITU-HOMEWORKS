`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Berk Özcan 150220107
//  Ayberk Gürses 150220055
//
//  BLG222E Assignment 1 - Part 2a
//  Instruction Register
//////////////////////////////////////////////////////////////////////////////////


module InstructionRegister(
    input [7:0] I,
    input Write,
    input LH,
    input Clock,
    output reg [15:0] IROut
    );
    
    always @(posedge Clock)
    begin
        if(Write)
        begin
            case (LH)
            1'b1: IROut[15:8] <= I;
            1'b0: IROut[7:0] <= I;
            endcase
        end
        else
        begin
            IROut <= IROut;
        end
    end
endmodule
