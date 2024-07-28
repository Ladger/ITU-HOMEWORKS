`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Berk Özcan 150220107 
// Ayberk Gürses 150220055
//
// BLG22E Assignment 1 - Part 2c
// Arithmetic Logic Unit
//////////////////////////////////////////////////////////////////////////////////

module ArithmeticLogicUnit(
    input [15:0] A,
    input [15:0] B,
    input [4:0] FunSel,
    input WF,
    input Clock,
    output reg [15:0] ALUOut,
    output reg [3:0] FlagsOut
    );
    
    
    reg Z = 0;
    reg C = 0;
    reg N = 0;
    reg O = 0;
    
    always @(posedge Clock)
    begin
        if (WF)
        begin
            FlagsOut <= {Z,C,N,O};
        end
    end
    
    always @(*)
    begin
        case (FunSel)
            5'b00000: begin 
                ALUOut <= {{8{A[7]}}, A[7:0]};
                
                if (ALUOut[7] == 1) begin
                    N = 1;
                end else begin
                    N = 0;
                    end
                end
            5'b00001: begin 
                ALUOut <= {{8{B[7]}}, B[7:0]};
                
                if (ALUOut[7] == 1) begin
                    N = 1;
                end else begin
                    N = 0;
                    end
                end
            
            /////////////////////////
            
            5'b00010: begin
            ALUOut <= {{8{~A[7]}}, ~A[7:0]};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end            
            5'b00011: begin
            ALUOut <= {{8{~B[7]}}, ~B[7:0]};
                        
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            ////////////////////
            
            5'b00100: begin
            {C, ALUOut[7:0]} <= {1'b0, A[7:0]} + {1'b0, B[7:0]};
            ALUOut[15:8] <= {8{ALUOut[7]}};
            
            if ((A[7] == B[7]) && (A[7] != ALUOut[7])) begin
                O = 1;
            end else begin
                O = 0;
                end
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b00101: begin
            {C, ALUOut[7:0]} <= {1'b0, A[7:0]} + {1'b0, B[7:0]} + {8'b0, FlagsOut[2]};
            ALUOut[15:8] <= {8{ALUOut[7]}};
            
            if ((A[7] == B[7]) && (A[7] != ALUOut[7])) begin
                O = 1;
            end else begin
                O = 0;
                end
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b00110: begin
            {C, ALUOut[7:0]} <= {1'b0, A[7:0]} + {1'b0, (~B[7:0] + 8'd1)};
            ALUOut[15:8] <= {8{ALUOut[7]}};
            
            if ((A[7] != B[7]) && (A[7] != ALUOut[7])) begin
                O = 1;
            end else begin
                O = 0;
                end
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            ///////////////////
            
            5'b00111: begin
            ALUOut <= {8'd0, A[7:0] & B[7:0]};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01000: begin
            ALUOut <= {8'd0, A[7:0] | B[7:0]};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01001: begin
            ALUOut <= {8'd0, A[7:0] ^ B[7:0]};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01010: begin
            ALUOut <= {8'd0, ~A[7:0] | ~B[7:0]};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            ///////////////////
            
            5'b01011: begin
            C <= A[7];
            ALUOut[7:0] <= A[7:0] << 1;
            ALUOut[15:8] <= {8{ALUOut[7]}};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01100: begin
            C <= A[0];
            ALUOut[7:0] <= A[7:0] >> 1;
            ALUOut[15:8] <= {8{ALUOut[7]}};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01101: begin
            ALUOut[7:0] <= {ALUOut[7], ALUOut[7:1]};
            ALUOut[15:8] <= {8{ALUOut[7]}};
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01110: begin
            ALUOut[7:0] <= {A[6:0], C};
            ALUOut[15:8] <= {8{ALUOut[7]}};
            C <= A[7];
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b01111: begin
            ALUOut[7:0] <= {C, A[7:1]};
            ALUOut[15:8] <= {8{ALUOut[7]}};
            C <= A[0];
            
            if (ALUOut[7] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            // 8-bit
            ///////////////////
            // 16-bit
            
            5'b10000: begin
            ALUOut <= A;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b10001: begin
            ALUOut <= B;
           
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            ///////////////////////
            
            5'b10010: begin
            ALUOut <= ~A;
           
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b10011: begin
            ALUOut <= ~B;
           
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            //////////////////////
            
            5'b10100: begin
            {C, ALUOut} <= {1'b0, A} + {1'b0, B};
            
            if ((A[15] == B[15]) && (A[15] != ALUOut[15])) begin
                O = 1;
            end else begin
                O = 0;
                end
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b10101: begin
            {C, ALUOut} <= {1'b0, A} + {1'b0, B} + {16'b0, FlagsOut[2]};
            
            if ((A[15] == B[15]) && (A[15] != ALUOut[15])) begin
                O = 1;
            end else begin
                O = 0;
                end
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b10110: begin
            {C, ALUOut} <= {1'b0, A} + {1'b0, (~B + 16'b1)};
            
            if ((A[15] != B[15]) && (A[15] != ALUOut[15])) begin
                O = 1;
            end else begin
                O = 0;
                end
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            
            //////////////////////
            
            5'b10111: begin
            ALUOut <= A & B;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11000: begin
            ALUOut <= A | B;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11001: begin
            ALUOut <= A ^ B;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11010: begin
            ALUOut <= ~A | ~B;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11011: begin
            C <= A[15];
            ALUOut <= A << 1;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11100: begin
            C <= A[0];
            ALUOut <= A >> 1;
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11101: begin
            ALUOut = {ALUOut[15], ALUOut[15:1]};
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11110: begin
            ALUOut <= {ALUOut[14:0], C};
            C <= A[15];
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
            5'b11111: begin
            ALUOut <= {C, ALUOut[15:1]};
            C <= A[0];
            
            if (ALUOut[15] == 1) begin
                N = 1;
            end else begin
                N = 0;
                end
            end
        endcase
        
        if (ALUOut == 16'd0) begin
            Z = 1;
        end
        else begin
            Z = 0;
        end
        
    end
    
endmodule
