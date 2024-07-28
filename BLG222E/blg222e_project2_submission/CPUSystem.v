`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Berk Özcan 150220107 
// Ayberk Gürses 150220055
//
// BLG22E Assignment 2
// CPU
//////////////////////////////////////////////////////////////////////////////////

module Decoder_4TO16(
    input [3:0] in,
    output [15:0] out
);
    
    reg [15:0] out_case;
    integer i;

  always @* begin
    out_case = {16{1'b0}}; 
    for (i = 0; i < 16; i = i + 1) begin
      if (in == i)
        out_case[i] = 1'b1;
    end
  end

  assign out = out_case;
endmodule

module Decoder_6TO64(
    input [5:0] in,
    output [63:0] out
);
    
    reg [63:0] out_case;
    integer i;

  always @* begin
    out_case = {64{1'b0}}; 
    for (i = 0; i < 64; i = i + 1) begin
      if (in == i)
        out_case[i] = 1'b1;
    end
  end

  assign out = out_case;
endmodule

module CPUSystem(input Clock, input Reset, output [15:0] T);

    reg [2:0] RF_OutASel;
    reg [2:0] RF_OutBSel; 
    reg [2:0] RF_FunSel; 
    reg [3:0] RF_RegSel; 
    reg [3:0] RF_ScrSel;
        
    reg [4:0] ALU_FunSel; 
    reg ALU_WF;
        
    reg [1:0] ARF_OutCSel; 
    reg [1:0] ARF_OutDSel; 
    reg [2:0] ARF_FunSel; 
    reg [2:0] ARF_RegSel;
        
    reg IR_LH; 
    reg IR_Write; 
        
    reg Mem_WR;
    reg Mem_CS;
        
    reg [1:0] MuxASel; 
    reg [1:0] MuxBSel; 
    reg MuxCSel;
    
    wire [3:0] FlagsOut;
    
    ArithmeticLogicUnitSystem _ALUSystem(
        RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel,
        ALU_FunSel, ALU_WF,
        ARF_OutCSel, ARF_OutDSel, ARF_FunSel, ARF_RegSel,
        IR_LH, IR_Write, 
        Mem_WR, Mem_CS,
        MuxASel, MuxBSel, MuxCSel,
        Clock,
        FlagsOut
    );
    
    reg [2:0] s_counter_funsel;
    Register s_counter(
        .FunSel(s_counter_funsel),
        .Clock(Clock),
        .E(1'b1)
    );
    
    // timing signals
    Decoder_4TO16 time_decoder(.in(s_counter.Q[3:0]), .out(T));

    // opcode decode
    wire [63:0] D;
    Decoder_6TO64 opcode_decoder(.in(_ALUSystem.IROut), .out(D));
    
    // First Instruction Type
    wire [3:0] d_RSel;
    wire [15:4] d_RSel_void;
    Decoder_4TO16 RSel_decoder(.in(_ALUSystem.IROut[9:8]), .out({d_RSel_void, d_RSel}));
    
    // Second Instruction Type
    wire [1:0] d_S;
    wire [15:2] d_S_void;
    Decoder_4TO16 S_decoder(.in(_ALUSystem.IROut[9]), .out({d_S_void, d_S}));
    
    wire [7:0] d_DSTReg;
    wire [15:8] d_DSTReg_void;
    Decoder_4TO16 DSTReg_decoder(.in(_ALUSystem.IROut[8:6]), .out({d_DSTReg_void, d_DSTReg}));
    
    wire [7:0] d_SReg1;
    wire [15:8] d_SReg1_void;
    Decoder_4TO16 SReg1_decoder(.in(_ALUSystem.IROut[5:3]), .out({d_SReg1_void,d_SReg1}));
        
    wire [7:0] d_SReg2;
    wire [15:8] d_SReg2_void;
    Decoder_4TO16 SReg2_decoder(.in(_ALUSystem.IROut[2:0]), .out({d_SReg2_void,d_SReg2}));
    
    initial begin
        $dumpvars; // Dumping all variables into simulation view
        s_counter_funsel = 3'b001;
    end
    always @(*) begin
        if (Reset) begin
            s_counter_funsel = 3'b011;
            ARF_FunSel = 3'b011;
            ARF_RegSel = 3'b000;
        end
        if (!Reset) begin
            if (T[0]) begin
                IR_Write = 1;
                IR_LH = 0;
                
                Mem_WR = 0;
                Mem_CS = 0;
                
                // PC <- PC + 1
                ARF_OutDSel = 2'b00;
                ARF_FunSel = 3'b001;
                ARF_RegSel = 3'b011;
                
                // Incrementing timing signal
                s_counter_funsel = 3'b001;
                RF_RegSel = 4'b1111;
            end
            if (T[1]) begin
                IR_Write = 1;
                IR_LH = 1;
                
                Mem_WR = 0;
                Mem_CS = 0;
                
                // PC <- PC + 1
                ARF_OutDSel = 2'b00;
                ARF_FunSel = 3'b001;
                ARF_RegSel = 3'b011;
                
                // Incrementing timing signal
                s_counter_funsel = 3'b001;
                RF_RegSel = 4'b1111;
            end
            
            // BRA
            if (T[2] && D[0]) begin
                RF_RegSel = 4'b1111;
                
                MuxBSel = 2'b11;
                ARF_RegSel = 3'b011;
                ARF_FunSel = 3'b010;
                
                Mem_CS = 1;
                s_counter_funsel = 3'b011;
                IR_Write = 0;
            end
            
            // BNE
            if(!FlagsOut[0]) begin
                RF_RegSel = 4'b1111;
                
                MuxBSel = 2'b11;
                ARF_RegSel = 4'b011;
                ARF_FunSel = 2'b010;
            
                
                Mem_CS = 1;
                s_counter_funsel = 3'b011;
                IR_Write = 0;
            end
            
            // BEQ
            if(FlagsOut[0]) begin
                RF_RegSel = 4'b1111;
                
                MuxBSel = 2'b11;
                ARF_RegSel = 4'b011;
                ARF_FunSel = 2'b010;
            
                
                Mem_CS = 1;
                s_counter_funsel = 3'b011;
                IR_Write = 0;
            end
            
            // POP
            if (T[2] && D[3]) begin
              MuxASel = 2'b01;
              
              RF_RegSel = {d_RSel[0], d_RSel[1], d_RSel[2], d_RSel[3]};
              RF_FunSel = 3'b010;
        
              
              ARF_OutDSel = 2'b11;
              Mem_CS = 0;
              Mem_WR = 0;
        
              
              ARF_RegSel = 3'b110;
              ARF_FunSel = 3'b001;
        
              IR_Write = 0;
              s_counter_funsel = 3'b011;
            end
            
            // PSH
            if (T[2] && D[4]) begin
              Mem_WR = 0;
              
              
              ARF_RegSel = 3'b110;
              ARF_FunSel = 3'b000;     
              IR_Write = 1;
              
              s_counter_funsel = 3'b001;
            end  
            
            if (T[3] && D[4]) begin // write low
              
              Mem_CS = 0;
              Mem_WR = 1;
              ARF_OutDSel = 2'b11;
              ARF_RegSel = 3'b000;
              
              
              ALU_FunSel = 5'b10001;
              if (d_RSel[0]) RF_OutBSel = 3'b100;
              if (d_RSel[1]) RF_OutBSel = 3'b101;
              if (d_RSel[2]) RF_OutBSel = 3'b110;
              if (d_RSel[3]) RF_OutBSel = 3'b111;
              
              MuxCSel = 0;
              s_counter_funsel = 3'b001;
              IR_Write = 1;
            end
            if (T[4] && D[4]) begin // write high
                Mem_CS = 0;
              Mem_WR = 1;
              ARF_OutDSel = 2'b11;
              ARF_RegSel = 3'b000;
              
              
              ALU_FunSel = 5'b10001;
              if (d_RSel[0]) RF_OutBSel = 3'b100;
              if (d_RSel[1]) RF_OutBSel = 3'b101;
              if (d_RSel[2]) RF_OutBSel = 3'b110;
              if (d_RSel[3]) RF_OutBSel = 3'b111;
              
              MuxCSel = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 1;
            
            end
            
            
            // INC
            if (T[2] && D[5]) begin
        
                MuxASel = 2'b00;
                MuxBSel = 2'b00;
                ALU_FunSel = 4'b0000;
                
                if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  
                  RF_FunSel = 3'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                  ARF_RegSel = 3'b0;
                end
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
                
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 3'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                  RF_RegSel = 4'b1111;
                end
                
                if (d_SReg1[4]) ARF_OutCSel = 2'b11; 
                if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
                if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
                if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
               
                Mem_CS = 1; 
                IR_Write = 0;
                s_counter_funsel = 3'b001;
            end  
        
            if (T[3] && D[5]) begin
                
                if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 3'b001;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                  ARF_RegSel = 3'b000;
                end
        
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b001;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                  RF_RegSel = 4'b1111;
                end
                
                Mem_CS = 1;
                s_counter_funsel = 3'b011;
                IR_Write = 0;
                
            end
            
            // INC
            if (T[2] && D[6]) begin
        
                MuxASel = 2'b00;
                MuxBSel = 2'b00;
                ALU_FunSel = 4'b0000;
                
                if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  
                  RF_FunSel = 3'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                  ARF_RegSel = 3'b0;
                end
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
                
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 3'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                  RF_RegSel = 4'b1111;
                end
                
                if (d_SReg1[4]) ARF_OutCSel = 2'b11; 
                if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
                if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
                if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
               
                Mem_CS = 1; 
                IR_Write = 0;
                s_counter_funsel = 3'b001;
            end  
        
            if (T[3] && D[6]) begin
                
                if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 3'b000;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                  ARF_RegSel = 3'b000;
                end
        
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b000;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                  RF_RegSel = 4'b1111;
                end
                
                Mem_CS = 1;
                s_counter_funsel = 3'b011;
                IR_Write = 0;
            end
            
            // LSL
            if (T[2] && D[7]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 2'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 2'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
              if (d_SReg1[0]) RF_OutASel = 3'b100;
              if (d_SReg1[1]) RF_OutASel = 3'b101;
              if (d_SReg1[2]) RF_OutASel = 3'b110;
              if (d_SReg1[3]) RF_OutASel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7])
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
        
              ALU_FunSel = 5'b01011;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // LSR
            if (T[2] && D[8]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 2'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 2'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
              if (d_SReg1[0]) RF_OutASel = 3'b100;
              if (d_SReg1[1]) RF_OutASel = 3'b101;
              if (d_SReg1[2]) RF_OutASel = 3'b110;
              if (d_SReg1[3]) RF_OutASel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7])
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
        
              ALU_FunSel = 5'b01100;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // ASR
            if (T[2] && D[9]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 2'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 2'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
              if (d_SReg1[0]) RF_OutASel = 3'b100;
              if (d_SReg1[1]) RF_OutASel = 3'b101;
              if (d_SReg1[2]) RF_OutASel = 3'b110;
              if (d_SReg1[3]) RF_OutASel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7])
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
        
              ALU_FunSel = 5'b01101;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // CSL
            if (T[2] && D[10]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 2'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 2'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
              if (d_SReg1[0]) RF_OutASel = 3'b100;
              if (d_SReg1[1]) RF_OutASel = 3'b101;
              if (d_SReg1[2]) RF_OutASel = 3'b110;
              if (d_SReg1[3]) RF_OutASel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7])
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
        
              ALU_FunSel = 5'b01110;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // CSR
            if (T[2] && D[11]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 2'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 2'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
              if (d_SReg1[0]) RF_OutASel = 3'b100;
              if (d_SReg1[1]) RF_OutASel = 3'b101;
              if (d_SReg1[2]) RF_OutASel = 3'b110;
              if (d_SReg1[3]) RF_OutASel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7])
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
        
              ALU_FunSel = 5'b01111;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // AND
            if (T[2] && D[12]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00111;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // ORR
            if (T[2] && D[13]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b01000;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end 
            
            // NOT
            if (T[2] && D[14]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 2'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 2'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
              if (d_SReg1[0]) RF_OutASel = 3'b100;
              if (d_SReg1[1]) RF_OutASel = 3'b101;
              if (d_SReg1[2]) RF_OutASel = 3'b110;
              if (d_SReg1[3]) RF_OutASel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7])
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00; 
        
              ALU_FunSel = 5'b00010;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // XOR
            if (T[2] && D[15]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b01001;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end    
            
            // NAND
            if (T[2] && D[16]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00111;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end 
            
            ///////////
            //
            //
            //
            // MOVH
            //
            //
            //
            //////////
            
            ///////////
            //
            //
            //
            // LDR
            //
            //
            //
            //////////
            
            ///////////
            //
            //
            //
            // STR
            //
            //
            //
            //////////
            
            ///////////
            //
            //
            //
            // MOVL
            //
            //
            //
            //////////
            
            // ADD
            if (T[2] && D[21]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00100;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // ADC
            if (T[2] && D[22]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00101;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // SUB
            if (T[2] && D[23]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00110;
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // MOVS
            if (T[2] && D[24]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                RF_FunSel = 3'b010;
                RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
              end
              
              if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                ARF_FunSel = 3'b010;
                ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
              end
        
              if (d_SReg1[0] || d_SReg1[1] || d_SReg1[2] || d_SReg1[3])
                ALU_FunSel = 5'b00001;
              if (d_SReg1[0]) RF_OutBSel = 3'b100;
              if (d_SReg1[1]) RF_OutBSel = 3'b101;
              if (d_SReg1[2]) RF_OutBSel = 3'b110;
              if (d_SReg1[3]) RF_OutBSel = 3'b111;
              
              if (d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) 
                ALU_FunSel = 5'b00000;
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10;
              if (d_SReg1[6]) ARF_OutCSel = 2'b01;
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
              
              ALU_WF = 1; // Write Flags
              Mem_WR = 0;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // ADDS
            if (T[2] && D[25]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00100;
              ALU_WF = 1; // Write Flags
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // SUBS
            if (T[2] && D[26]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00110;
              ALU_WF = 1; // Write Flags
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // ANDS
            if (T[2] && D[27]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b00111;
              ALU_WF = 1; // Write Flags
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // ORS
            if (T[2] && D[28]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b01000;
              ALU_WF = 1; // Write Flags
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
            // XORS
            if (T[2] && D[29]) begin
              MuxASel = 2'b00;
              MuxBSel = 2'b00;
        
              if (d_DSTReg[0] || d_DSTReg[1] || d_DSTReg[2] || d_DSTReg[3]) begin
                  RF_FunSel = 2'b010;
                  RF_RegSel = {d_DSTReg[0], d_DSTReg[1], d_DSTReg[2], d_DSTReg[3]};
                end
                
                if (d_DSTReg[4] || d_DSTReg[5] || d_DSTReg[6] || d_DSTReg[7]) begin
                  ARF_FunSel = 2'b010;
                  ARF_RegSel = {d_DSTReg[5], d_DSTReg[4], d_DSTReg[6], d_DSTReg[7]};
                end
        
              if (d_SReg1[4]) ARF_OutCSel = 2'b11;
              if (d_SReg1[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg1[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg1[7]) ARF_OutCSel = 2'b00;
        
              if (d_SReg2[4]) ARF_OutCSel = 2'b11;
              if (d_SReg2[5]) ARF_OutCSel = 2'b10; 
              if (d_SReg2[6]) ARF_OutCSel = 2'b00; 
              if (d_SReg2[7]) ARF_OutCSel = 2'b00;
              
              if ((d_SReg1[4] || d_SReg1[5] || d_SReg1[6] || d_SReg1[7]) || 
                 (d_SReg2[4] || d_SReg2[5] || d_SReg2[6] || d_SReg2[7])) begin
                
                if (d_SReg1[0]) RF_OutBSel = 3'b100;
                if (d_SReg1[1]) RF_OutBSel = 3'b101;
                if (d_SReg1[2]) RF_OutBSel = 3'b110;
                if (d_SReg1[3]) RF_OutBSel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end else begin
                
                if (d_SReg1[0]) RF_OutASel = 3'b100;
                if (d_SReg1[1]) RF_OutASel = 3'b101;
                if (d_SReg1[2]) RF_OutASel = 3'b110;
                if (d_SReg1[3]) RF_OutASel = 3'b111;
        
                if (d_SReg2[0]) RF_OutBSel = 3'b100;
                if (d_SReg2[1]) RF_OutBSel = 3'b101;
                if (d_SReg2[2]) RF_OutBSel = 3'b110;
                if (d_SReg2[3]) RF_OutBSel = 3'b111;
              end
        
              ALU_FunSel = 5'b01001;
              ALU_WF = 1; // Write Flags
              Mem_CS = 1;
              s_counter_funsel = 3'b011;
              IR_Write = 0;
            end
            
        end
    end
    
endmodule
