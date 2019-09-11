`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:23:43 PM
// Design Name: 
// Module Name: alu
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

module alu#(
        parameter DATA_WIDTH = 32,
        parameter OPCODE_LENGTH = 4
        )(
        input logic [DATA_WIDTH-1:0]    SrcA,
        input logic [DATA_WIDTH-1:0]    SrcB,
	input logic [2:0] Branch_Type,
        input logic [OPCODE_LENGTH-1:0]    Operation,
        
	output logic Zero,
        output logic[DATA_WIDTH-1:0] ALUResult
        );

	assign Zero = (
                      ((Branch_Type == 3'b010) && (($signed(SrcA) - $signed(SrcB)) == 1'b0)) ||        // BEQ
                      ((Branch_Type == 3'b001) && (($signed(SrcA) - $signed(SrcB)) != 1'b0)) ||        // BNE
                      ((Branch_Type == 3'b100) && (($signed(SrcA) < $signed(SrcB)) == 1'b1)) ||        // BLT
                      ((Branch_Type == 3'b110) && (($unsigned(SrcA) < $unsigned(SrcB)) == 1'b1)) ||    // BLTU
                      ((Branch_Type == 3'b101) && (($signed(SrcA) >= $signed(SrcB)) == 1'b1)) ||       // BGE
                      ((Branch_Type == 3'b111) && (($unsigned(SrcA) >= $unsigned(SrcB)) == 1'b1))      // BGEU
                      );

	always_comb
	 begin
  	 ALUResult = 'd0;
  	 case(Operation)
 /*0*/ 	 4'b0000:     // AND  
      		ALUResult = SrcA & SrcB;
 /*1*/ 	 4'b0001:     // OR   
      		ALUResult = SrcA | SrcB;
 /*2*/ 	 4'b0010:     // ADD   
      		ALUResult = SrcA + SrcB;
 /*3*/ 	 4'b0011:     // SLL		
      		ALUResult = SrcA << SrcB;
 /*4*/ 	 4'b0100:     // SRA		
      		ALUResult = $signed(SrcA) >>> $signed(SrcB);
 /*5*/ 	 4'b0101:     // SRL		
      		ALUResult = SrcA >> SrcB;
 /*6*/ 	 4'b0110:     // SUB   
      		ALUResult = $signed(SrcA) - $signed(SrcB);
 /*7*/ 	 4'b0111:     // XOR		
      		ALUResult = SrcA ^ SrcB;
 /*8*/ 	 4'b1000:     // SLT
      		ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1'b1 : 1'b0;
 /*9*/ 	 4'b1001:     // SLTU		
      		ALUResult = ($unsigned(SrcA) < $unsigned(SrcB)) ? 1'b1 : 1'b0;
 /*10*/  4'b1010:     // BGE	 	
     	 	ALUResult = ($signed(SrcA) >= $signed(SrcB)) ? 1'b1 : 1'b0;
 /*11*/	 4'b1011:     // BGEU		
      		ALUResult = ($unsigned(SrcA) >= $unsigned(SrcB)) ? 1'b1 : 1'b0;
 /*12*/  4'b1100:     // BLT		
      		ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1'b1 : 1'b0;
 /*13*/  4'b1101:     // BLTU		
      	 	ALUResult = ($unsigned(SrcA) < $unsigned(SrcB)) ? 1'b1 : 1'b0; 
  	 default:     
      		ALUResult = 'b0;
  	 endcase
	end

endmodule

