`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:22:44 PM
// Design Name: 
// Module Name: imm_Gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imm_Gen(
    input logic [31:0] inst_code,
    output logic [31:0] Imm_out);

logic [16:0] sraicheck;
logic [31:0] Imm_out1;

always_comb
    case(inst_code[6:0])
        7'b0000011:   // LOAD
            Imm_out1 = {inst_code[31] ? 20'b11111111111111111111 : 20'b0, inst_code[31:20]};
			
        7'b0010011:   // RTypeI
            Imm_out1 = {inst_code[31] ? 20'b11111111111111111111 : 20'b0, inst_code[31:20]};
			
        7'b0100011:   // SType
            Imm_out1 = {inst_code[31] ? 20'b11111111111111111111 : 20'b0, inst_code[31:25], inst_code[11:7]};
			
	7'b1100011:   // BRANCH
            Imm_out1 = {inst_code[31] ? 19'b1111111111111111111: 19'b0, inst_code[31], inst_code[7], inst_code[30:25], inst_code[11:8], 1'b0};
			
	7'b1100111:   // JALR
	    Imm_out1 = {inst_code[31] ? 20'b11111111111111111111 : 20'b0, inst_code[31:20]};
			
	7'b1101111:   // JAL
	    Imm_out1 = {inst_code[31] ? 11'b11111111111 : 11'b0, inst_code[31], inst_code[19:12], inst_code[20], inst_code[30:21], 1'b0};
		
	7'b0110111:   // LUI 
	    Imm_out1 = {inst_code[31:12], 12'b0};
			
	7'b0010111:   // AUIPC	
	    Imm_out1 = {inst_code[31:12], 12'b0};
			
        default: 
            Imm_out1 = {32'b0};
    endcase

// Special Case Srai
// sraicheck == {opcode, funct7, funct3}
assign sraicheck = {inst_code[6:0], inst_code[31:25], inst_code[14:12]};
assign Imm_out = (sraicheck==17'b00100110100000101) ? ({inst_code[24] ? 27'b111111111111111111111111111 : 27'b0, inst_code[24:20]}) : Imm_out1;
  
endmodule
