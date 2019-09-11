`timescale 1ns / 1ps

module riscv #(
    parameter DATA_W = 32)
    (input logic clk, reset, // clock and reset signals
    output logic [31:0] WB_Data// The ALU_Result
    );

/*logic [6:0] opcode;
logic ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jal, Jalr, Lui, Auipc;

logic [1:0] ALUop;
logic [6:0] Funct7;
logic [2:0] Funct3;
logic [2:0] Branch_Type;
logic [2:0] Load_Type;
logic [3:0] Operation;*/

    //Controller c(opcode, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jal, Jalr, Lui, Auipc, ALUop);

    //ALUController ac(ALUop, Funct7, Funct3, Load_Type, Branch_Type, Operation);

    Datapath dp(clk, reset, WB_Data);

endmodule
