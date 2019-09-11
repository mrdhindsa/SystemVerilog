`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:10:33 PM
// Design Name: 
// Module Name: ALUController
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


module ALUController(
    
    //Inputs
    input logic [1:0] ALUOp,  //7-bit opcode field from the instruction
    input logic [6:0] Funct7, // bits 25 to 31 of the instruction
    input logic [2:0] Funct3, // bits 12 to 14 of the instruction
    
    //Output
    output logic [2:0] Load_Type, // Signal set to determine the type of Load
    output logic [2:0] Branch_Type,
    output logic [3:0] Operation //operation selection for ALU
);

assign Load_Type[0] = /*LB/LH/LHU*/ ((ALUOp == 2'b00 && Funct3 == 3'b000) || (ALUOp == 2'b00 && Funct3 == 3'b001) || (ALUOp == 2'b00 && Funct3 == 3'b101));
assign Load_Type[1] = /*LB/LW*/ ((ALUOp == 2'b00 && Funct3 == 3'b000) || (ALUOp == 2'b00 && Funct3 == 3'b010));
assign Load_Type[2] = /*LB/LBU/LHU*/ ((ALUOp == 2'b00 && Funct3 == 3'b000) || (ALUOp == 2'b00 && Funct3 == 3'b100) || (ALUOp == 2'b00 && Funct3 == 3'b101));
 
/* Branc_Type for BEQ == 010 */
assign Branch_Type[0] = /*BNE/BGE/BGEU*/ ((ALUOp == 2'b01 && Funct3 == 3'b001) || (ALUOp == 2'b01 && Funct3 == 3'b101) || (ALUOp == 2'b01 && Funct3 == 3'b111));
assign Branch_Type[1] = /*BEQ/BLTU/BGEU*/ ((ALUOp == 2'b01 && Funct3 == 3'b000) || (ALUOp == 2'b01 && Funct3 == 3'b110) || (ALUOp == 2'b01 && Funct3 == 3'b111));
assign Branch_Type[2] = /*BLT/BGE/BLTU/BGEU*/ ((ALUOp == 2'b01 && Funct3 == 3'b100) || (ALUOp == 2'b01 && Funct3 == 3'b101) ||
		(ALUOp == 2'b01 && Funct3 == 3'b110) || (ALUOp == 2'b01 && Funct3 == 3'b111));

assign Operation[0] =  (/*OR/ORI*/(ALUOp == 2'b10 && Funct3 == 3'b110) || /*SLL/SLLI*/(ALUOp == 2'b10 && Funct3 == 3'b001) ||				
	/*SRL/SRLI*/(ALUOp == 2'b10 && Funct3 == 3'b101 && Funct7 == 7'b0000000) || /*XOR/XORI*/(ALUOp == 2'b10 && Funct3 == 3'b100) ||			
	/*SLTU/SLTIU*/(ALUOp == 2'b10 && Funct3 == 3'b011) || /*BGEU*/(ALUOp == 2'b01 && Funct3 == 3'b111) ||	
	/*BLTU*/(ALUOp == 2'b01 && Funct3 == 3'b110));

assign Operation[1] =  (/*ADD/ADDI/SUB*/(ALUOp == 2'b10 && Funct3 == 3'b000) ||	/*SLL/SLLI*/(ALUOp == 2'b10 && Funct3 == 3'b001) ||	
	/*XOR/XORI*/(ALUOp == 2'b10 && Funct3 == 3'b100) || /*BGE*/(ALUOp == 2'b01 && Funct3 == 3'b101) ||						
	/*BGEU*/(ALUOp == 2'b01 && Funct3 == 3'b111) || /*LW/SW*/(ALUOp == 2'b00) || /*BEQ*/(ALUOp == 2'b01 && Funct3 == 3'b000) || 
        /*BNE*/ (ALUOp == 2'b01 && Funct3 == 3'b001) || /*JAL/JALR/LUI/AUIPC*/(ALUOp == 2'b11));

assign Operation[2] =  (/*SRA/SRAI*/(ALUOp == 2'b10 && Funct3 == 3'b101 && Funct7 == 7'b0100000) || 
	/*SRL/SRLI*/(ALUOp == 2'b10 && Funct3 == 3'b101 && Funct7 == 7'b0000000) || 
	/*SUB*/(ALUOp == 2'b10 && Funct3 == 3'b000 && Funct7 == 7'b0100000) ||
	/*XOR/XORI*/(ALUOp == 2'b10 && Funct3 == 3'b100) || /*BLT*/(ALUOp == 2'b01 && Funct3 == 3'b100) ||
	/*BLTU*/(ALUOp == 2'b01 && Funct3 == 3'b110) || /*BEQ*/(ALUOp == 2'b01 && Funct3 == 3'b000) || 
        /*BNE*/ (ALUOp == 2'b01 && Funct3 == 3'b001));

assign Operation[3] = (/*SLT/SLTI*/(ALUOp == 2'b10 && Funct3 == 3'b010) || /*SLTU/SLTIU*/(ALUOp == 2'b10 && Funct3 == 3'b011) ||		
	/*BGE*/(ALUOp == 2'b01 && Funct3 == 3'b101) || /*BGEU*/(ALUOp == 2'b01 && Funct3 == 3'b111) ||
	/*BLT*/(ALUOp == 2'b01 && Funct3 == 3'b100) || /*BLTU*/(ALUOp == 2'b01 && Funct3 == 3'b110));

endmodule
