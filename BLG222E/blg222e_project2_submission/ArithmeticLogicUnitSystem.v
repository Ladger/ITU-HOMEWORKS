`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Berk Özcan 150220107 
// Ayberk Gürses 150220055
//
// BLG22E Assignment 1 - Part 4
// Arithmetic Logic Unit System
//////////////////////////////////////////////////////////////////////////////////

module MUX_4TO1(S, S0, S1, S2, S3, O);
    input wire [1:0] S;
    input wire [15:0] S0; 
    input wire [15:0] S1;
    input wire [15:0] S2;
    input wire [15:0] S3;
    output reg [15:0] O;

    always@(*) begin
        case(S)
            2'b00:  O<= S0;
            2'b01: O <= S1;
            2'b10: O <= S2;
            2'b11: O <= S3;
        endcase
    end
endmodule

module MUX_2TO1(S, S0, S1, O);
    input wire S;
    input wire [7:0] S0;
    input wire [7:0] S1;
    output reg [7:0] O;

    always@(*) begin
        case(S)
            1'b0: O <= S0;
            1'b1: O <= S1;
        endcase
    end
endmodule

module ArithmeticLogicUnitSystem(
    RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel,
    ALU_FunSel, ALU_WF,
    ARF_OutCSel, ARF_OutDSel, ARF_FunSel, ARF_RegSel,
    IR_LH, IR_Write, 
    Mem_WR, Mem_CS,
    MuxASel, MuxBSel, MuxCSel,
    Clock,
    FlagsOut
);
    
    // Instruction Register
    input wire IR_LH, IR_Write;
    wire [15:0] IROut;
    
    // Register File
    input wire [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    input wire [3:0] RF_RegSel, RF_ScrSel;
    wire [15:0] OutA, OutB;
    
    // Address Register File
    input wire [1:0] ARF_OutCSel, ARF_OutDSel;
    input wire [2:0] ARF_FunSel, ARF_RegSel;
    wire [15:0] OutC, OutD;
    
    // Arithmetic Logic Unit
    input wire [4:0] ALU_FunSel;
    input wire ALU_WF;
    output [3:0] FlagsOut;
    wire [15:0] ALUOut;
    
    // Memory
    input wire Mem_WR, Mem_CS;
    wire [7:0] MemOut;
    wire [15:0] Address;
    
    // MUX A
    input wire [1:0] MuxASel;
    wire [15:0] MuxAOut;
    
    // MUX B
    input wire [1:0] MuxBSel;
    wire [15:0] MuxBOut;
    
    // MUX C
    input wire MuxCSel;
    wire [7:0] MuxCOut;
    
    input wire Clock;
    assign Address = OutD;
    
    InstructionRegister IR(.I(MemOut), .Write(IR_Write), .LH(IR_LH), 
                           .Clock(Clock), .IROut(IROut));
                                
    RegisterFile RF(.I(MuxAOut), .OutASel(RF_OutASel), .OutBSel(RF_OutBSel), 
                    .FunSel(RF_FunSel), .RegSel(RF_RegSel), .ScrSel(RF_ScrSel), 
                    .Clock(Clock), .OutA(OutA), .OutB(OutB));
                                                    
    AddressRegisterFile ARF(.I(MuxBOut), .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel), 
                            .FunSel(ARF_FunSel), .RegSel(ARF_RegSel), .Clock(Clock), 
                            .OutC(OutC), .OutD(OutD));
                            
    ArithmeticLogicUnit ALU(.A(OutA), .B(OutB), .FunSel(ALU_FunSel), .WF(ALU_WF), 
                            .Clock(Clock), .ALUOut(ALUOut), .FlagsOut(FlagsOut));
                            
    Memory MEM(.Clock(Clock), .Address(Address), .Data(MuxCOut), 
               .WR(Mem_WR), .CS(Mem_CS), .MemOut(MemOut));
               
   MUX_4TO1 MUX_A(
       .S(MuxASel), 
       .S0(ALUOut), 
       .S1(OutC), 
       .S2(MemOut), 
       .S3(IROut[7:0]), 
       .O(MuxAOut)
   );
   
  MUX_4TO1 MUX_B(
       .S(MuxBSel), 
       .S0(ALUOut), 
       .S1(OutC), 
       .S2(MemOut), 
       .S3(IROut[7:0]), 
       .O(MuxBOut)
   );
   
   MUX_2TO1 MUX_C(
       .S(MuxCSel), 
       .S0(ALUOut[7:0]), 
       .S1(ALUOut[15:8]), 
       .O(MuxCOut)
   );
    
endmodule