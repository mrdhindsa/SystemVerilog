`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/07/2018 10:10:33 PM
// Design Name:
// Module Name: Datapath
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

module Datapath #(
    parameter PC_W = 9, // Program Counter
    parameter INS_W = 32, // Instruction Width
    parameter RF_ADDRESS = 5, // Register File Address
    parameter DATA_W = 32, // Data WriteData
    parameter DM_ADDRESS = 9, // Data Memory Address
    parameter ALU_CC_W = 4 // ALU Control Code Width
    )(
    input logic clk , reset , // global clock
                              // reset , sets the PC to zero
    output logic [DATA_W-1:0] WB_Data //ALU_Result
    );

logic [PC_W-1:0] PC, PCPlus4;
logic [INS_W-1:0] Instr;
logic [DATA_W-1:0] Result;
logic [DATA_W-1:0] Result1;
logic [DATA_W-1:0] Reg1, Reg2;
logic [DATA_W-1:0] ReadData;
logic [DATA_W-1:0] SrcB, ALUResult;
logic [DATA_W-1:0] ExtImm;

logic [31:0] PCPlusimm;
logic [8:0] newPC;
logic [8:0] newPC1;

logic Zero;
logic clockMuxselect;

logic [DATA_W-1:0] WB_Data1;
logic [DATA_W-1:0] SrcA1;
logic [DATA_W-1:0] SrcA2;
logic [DATA_W-1:0] SrcA3;

logic [DATA_W-1:0] SrcB1;
logic [DATA_W-1:0] SrcB2;
logic [DATA_W-1:0] SrcB3;

logic [DATA_W-1:0] PChold;
logic resmux1sel;

/// Inputs and Outputs of Controller and ALUController are now logics ///
logic [6:0] opcode;
logic ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jal, Jalr, Lui, Auipc;

logic [1:0] ALUop;
logic [6:0] Funct7;
logic [2:0] Funct3;
logic [2:0] Branch_Type;
logic [2:0] Load_Type;
logic [3:0] Operation;

/// Updates for Forwarding Unit ///
logic [1:0] forwardA;
logic [1:0] forwardB;

/* Updates for pipeline */ //Add the Sizes for each new input and output
logic [40:0] IF_ID_register_in;
logic [148:0] ID_EX_register_in;
logic [111:0] EX_MEM_register_in;
logic [73:0] MEM_WB_register_in;

logic [40:0] IF_ID_register_out;
logic [148:0] ID_EX_register_out;
logic [111:0] EX_MEM_register_out;
logic [73:0] MEM_WB_register_out;
/* Updates for pipeline */


/// For store_type ///
logic [DATA_W-1:0] Reg2new;
logic [2:0] store_type;

///////////////// Instruction Fetch (IF) /////////////////////

// PC Update. PC is made to just update to PC+4
    //assign PChold = {23'b0, PC};
    adder #(9) pcadd4 (PC, 9'b100, PCPlus4);
    //assign clockMuxselect = (Zero & Branch) | Jal; //redefine with EX_MEM_register_out
    //mux2 #(9) clockMux (PCPlus4, PCPlusimm[8:0] /* Comes from EX_MEM_register_out*/, clockMuxselect, newPC); // Checking For Branch and Jal (Both use PC+imm)
    //mux2 #(9) clockMux2 (newPC, ALUResult[8:0], Jalr, newPC1); // Checking for Jalr
    flopr #(9) pcreg(clk, reset, PCPlus4, PC);

 //Instruction memory
    instructionmemory instr_mem (PC, Instr);

    assign IF_ID_register_in = {PC, /*Instruction*/ Instr};
    // flopr1
    flopr #(41) IF_ID_register(clk, reset, IF_ID_register_in, IF_ID_register_out);
////////////////// Instruction Fetch (IF) /////////////////////

////////////////// Instruction Decode (ID) /////////////////////

  /*assign opcode = IF_ID_register_out[6:0];
    assign Funct7 = IF_ID_register_out[31:25];
    assign Funct3 = IF_ID_register_out[14:12];*/

//  Controller
    Controller c(IF_ID_register_out[6:0], ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jal, Jalr, Lui, Auipc, ALUop);

//  Register File
    RegFile rf(clk, reset, /*RegWrite*/ MEM_WB_register_out[68], IF_ID_register_out[11:7], IF_ID_register_out[19:15], IF_ID_register_out[24:20],
            Result, Reg1, Reg2);

//  Sign Extend
    imm_Gen Ext_Imm (IF_ID_register_out[31:0],ExtImm);


assign ID_EX_register_in = {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jal, Jalr, Lui, Auipc, ALUop,/*PC*/ IF_ID_register_out[40:32],/*Instruction*/ IF_ID_register_out[31:0],/*Reg1*/ Reg1, /*Reg2*/ Reg2, /*Immediate*/ ExtImm};
// flopr2
flopr #(149) ID_EX_register(clk, reset, ID_EX_register_in, ID_EX_register_out);
////////////////// Instruction Decode (ID) /////////////////////


////////////////// Instruction Execution (EXE) /////////////////

//  ALUController
    ALUController ac(/*ALUop*/ ID_EX_register_out[138:137], /*Funct7*/ ID_EX_register_out[127:121], /*Funct3*/ ID_EX_register_out[110:108], Load_Type, Branch_Type, Operation);

    adder #(32) pcaddimm ({23'b0 ,/*PC*/ ID_EX_register_out[136:128]},/*ExtImm*/ ID_EX_register_out[31:0], PCPlusimm);


//// ALU /////////// This is the old implementation, Uncomment the lines to make it run /////////
    //mux2 #(32) srcA1mux(/*Reg1*/ ID_EX_register_out[95:64], 32'b0,/*Lui*/ ID_EX_register_out[140], SrcA1);    // LUI_Signal
    //mux2 #(32) srcA3mux(SrcA1,/*PC*/ {23'b0,/*PC*/ ID_EX_register_out[136:128]}, /*Auipc*/ ID_EX_register_out[139], SrcA2); // AUIPC_Signal
    //mux2 #(32) srcbmux(/*Reg2*/ ID_EX_register_out[63:32],/*ExtImm*/ ID_EX_register_out[31:0], /*ALUsrc*/ ID_EX_register_out[148], SrcB);
    //alu alu_module(SrcA2, SrcB, Branch_Type, Operation, Zero, ALUResult);
//////////////////// End of Old Implementation ///////////////////

//////// New ALU Implementation, using Forwarding //////////
mux2 #(32) srcA1mux(ID_EX_register_out[95:64], WB_Data, forwardA[0], SrcA1);
mux2 #(32) srcA2mux(SrcA1, EX_MEM_register_out[63:32], forwardA[0], SrcA2);


mux2 #(32) srcB1mux(ID_EX_register_out[63:32], WB_Data, forwardB[0], SrcB1);
mux2 #(32) srcB2mux(SrcB1, EX_MEM_register_out[63:32], forwardB[1], SrcB2);
mux2 #(32) srcB3mux(SrcB1, ID_EX_register_out[31:0], ID_EX_register_out[148], SrcB3);

alu alu_module(SrcA2, SrcB3, Branch_Type, Operation, Zero, ALUResult);

///////////// End of Forwarding ALU Implementation ///////////

    assign EX_MEM_register_in = {/*rd*/ ID_EX_register_out[107:103],/*Regwrite*/ ID_EX_register_out[146],/*MemtoReg*/ ID_EX_register_out[147],/*MemRead*/ ID_EX_register_out[145],/*MemWrite*/ ID_EX_register_out[144],/*Branch*/ ID_EX_register_out[143],/*Jal*/ ID_EX_register_out[142],/*Jalr*/ ID_EX_register_out[141], Load_Type, PCPlusimm, Zero, ALUResult, /*Reg2*/ ID_EX_register_out[63:32]};
    // flopr3
    flopr #(112) EX_MEM_register(clk, reset, EX_MEM_register_in, EX_MEM_register_out);
////////////////// Instruction Execution (EXE) /////////////////

///// Forwarding Unit
forwardingunit forward(/*rs1*/ ID_EX_register_out[115:111], /*rs2*/ ID_EX_register_out[120:116], /*ex_mem_rd*/ EX_MEM_register_out[111:107], /*mem_wb_rd*/ MEM_WB_register_out[73:69],/*EX_MEM_Regwrite*/ EX_MEM_register_out[106],/*MEM_WB_Regwrite*/ MEM_WB_register_out[68], forwardA, forwardB);

////////////////// Memory ///////////////////////

// SB = 001, SH = 010, SW = 100
assign store_type[0] = (/*Load_Type*/ EX_MEM_register_out[99:97]==3'b111 && /*MemWrite*/ EX_MEM_register_out[103]==1'b1);
assign store_type[1] = (/*Load_Type*/ EX_MEM_register_out[99:97]==3'b001 && /*MemWrite*/ EX_MEM_register_out[103]==1'b1);
assign store_type[2] = (/*Load_Type*/ EX_MEM_register_out[99:97]==3'b010 && /*MemWrite*/ EX_MEM_register_out[103]==1'b1);

always_comb
      begin
      case(store_type)
      3'b001:  // SB
            Reg2new = {EX_MEM_register_out[7]? 24'b111111111111111111111111:24'b0 , Reg2[7:0]};
      3'b010:  // SH
            Reg2new = {EX_MEM_register_out[15]? 16'b1111111111111111:16'b0 , Reg2[15:0]};
      default:
            Reg2new = EX_MEM_register_out[31:0];
      endcase
end

////// Data memory
	  datamemory data_mem (clk, /*MemRead*/ EX_MEM_register_out[104], /*MemWrite*/ EX_MEM_register_out[103], /*ALUResult[DM_ADDRESS-1:0]*/ EX_MEM_register_out[40:32], Reg2new, ReadData);

    assign MEM_WB_register_in = {/*rd*/ EX_MEM_register_out[111:107],/*Regwrite*/ EX_MEM_register_out[106],/*Load_Type*/ EX_MEM_register_out[99:97], /*MemtoReg*/ EX_MEM_register_out[105], /*ALUResult*/ EX_MEM_register_out[63:32], ReadData};
    // flopr4
    flopr #(74) MEM_WB_register(clk, reset, MEM_WB_register_in, MEM_WB_register_out);
/////////////// Memory //////////////////

/////////////// Write Back (WB) ///////////////////
//assign resmux1sel = Jal || Jalr;
mux2 #(32) resmux(/*ALUResult*/ MEM_WB_register_out[63:32], /*ReadData*/ MEM_WB_register_out[31:0], /*MemtoReg*/ MEM_WB_register_out[64], Result);
//mux2 #(32) resmux1(Result1, {23'b0, PCPlus4}, resmux1sel, Result);


/// Put this shit in the WB stage ///
    assign WB_Data1 = Result;
    always_comb
      begin
      case(MEM_WB_register_out[67:65])
      3'b111:  // LB
            WB_Data = {WB_Data1[7]? 24'b111111111111111111111111:24'b0 , WB_Data1[7:0]};
      3'b001:  // LH
            WB_Data = {WB_Data1[15]? 16'b1111111111111111:16'b0 , WB_Data1[15:0]};
      3'b010:  // LW
            WB_Data = WB_Data1;
      3'b100:  // LBU
            WB_Data = { 24'b0 , WB_Data1[7:0]};
      3'b101:  //LHU
            WB_Data = { 16'b0 , WB_Data1[15:0]};
      default:
            WB_Data = WB_Data1;
      endcase
    end

///////////////// Write Back (WB) ////////////////////

endmodule
