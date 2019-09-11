`timescale 1ns / 1ps

module forwardingunit(

        // Inputs
        input logic [4:0]    ID_EX_out_rs1,
        input logic [4:0]    ID_EX_out_rs2,
	input logic [4:0]    EX_MEM_out_rd,
        input logic [4:0]    MEM_WB_out_rd,
        input logic EX_MEM_RegWrite,
        input logic MEM_WB_Regwrite,

        // Outputs
	output logic [1:0] ForwardA,
        output logic [1:0] ForwardB
        );

assign ForwardA = (EX_MEM_RegWrite && (EX_MEM_out_rd != 0) && (EX_MEM_out_rd == ID_EX_out_rs1)) ? 2'b10 :
  (MEM_WB_Regwrite && (MEM_WB_out_rd != 0) && (MEM_WB_out_rd == ID_EX_out_rs1)) ? 2'b01 : 2'b00;

assign ForwardB = (EX_MEM_RegWrite && (EX_MEM_out_rd != 0) && (EX_MEM_out_rd == ID_EX_out_rs2)) ? 2'b10 :
  (MEM_WB_Regwrite && (MEM_WB_out_rd != 0) && (MEM_WB_out_rd == ID_EX_out_rs2)) ? 2'b01 : 2'b00;

endmodule
