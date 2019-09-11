`timescale 1ns / 1ps

/// 32-bit Arithmetic Logic Unit
module alu_32bit(
    input logic [31:0]  reg_1,
    input logic [31:0]  reg_2,
    input logic [3:0]   alu_opsel,
    output logic [31:0] alu_res
    );
    
    always @* begin
    case (alu_opsel)
        4'b1111 : alu_res = 32'b00000000000000000000000000000000;
        4'b0000 : alu_res = reg_1 + reg_2;
        4'b0011 : alu_res = reg_1 - reg_2;
        4'b1000 : alu_res = reg_1 & reg_2;
        4'b1001 : alu_res = reg_1 | reg_2;
        4'b1011 : alu_res = ~reg_1;
        4'b1010 : alu_res = reg_1 ^ reg_2;
        4'b1101 : alu_res = reg_1[31:0] << 1'b1;
        4'b0100 : alu_res = reg_1;
        4'b0110 : alu_res = reg_1;
        default : alu_res = 32'b00000000000000000000000000000000;
    endcase
    end
endmodule
