`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Berk Özcan 150220107 
// Ayberk Gürses 150220055
//
// BLG22E Assignment 1 - Part 1
// Register
//////////////////////////////////////////////////////////////////////////////////

module Register(
    input [2:0] FunSel, 
    input [15:0] I, 
    input Clock, 
    input E,
    output reg [15:0] Q);

always @(posedge Clock)
begin
    if (E)
    begin
        case(FunSel)
            3'b000: Q <= Q - 16'd1;
            3'b001: Q <= Q + 16'd1;
            3'b010: Q <= I;
            3'b011: Q <= 16'd0;
            3'b100: begin
                        Q[15:8] <= 8'd0;
                        Q[7:0] <= I[7:0];
                    end
            3'b101: begin
                        Q[15:8] <= Q[15:8];
                        Q[7:0] <= I[7:0];
                    end
            3'b110: begin
                        Q[15:8] <= I[15:8];
                        Q[7:0] <= Q[7:0];
                    end
            3'b111: begin
                        Q[15:8] <= I[7];
                        Q[7:0] <= I[7:0];
                    end
        endcase
     end
     else
     begin
        Q <= Q;
     end
end
endmodule
