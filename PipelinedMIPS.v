
`include "Register_File.v"
`include "Data_Memory_File.v"
`include "Instruction_Memory_File.v"
`include "Mux.v"
`include "SignExtension.v"
`include "ALU.v"
`include "Control.v"
`include "HazardUnit.v"

module PipelinedMIPS(Clk,Rst);

input Clk,Rst;
// Pipeline registers
reg  [ 63:0] IF_ID_pipereg;
reg  [190:0] ID_EX_pipereg;
reg  [107:0] EX_MEM_pipereg;
reg  [ 70:0] MEM_WB_pipereg;

reg  [ 31:0] PC_reg;

wire [ 31:0] Instruction,inc4_PC,PCout,DO,PCin;
wire [ 31:0] data1,data2,writeData,Extdata;
wire [ 31:0] ALUresult,B,ImOffset,Offset_add;
wire [ 31:0] JuOffset32,JA_ALUout;
wire [ 27:0] JuOffset28;
wire [  9:0] ControlWire1;
wire [  6:0] ControlWire2;
wire [  5:0] opCode,opCode_nop;
wire [  4:0] writeReg,writeReg2;
wire [  4:0] rsSel,rtSel,rdSel;
wire [  4:0] stall;
wire [  3:0] ALUCnt;
wire [  1:0] ALUOp;
wire [  1:0] ControlWire3;
wire 	     ALUsrc,regWrite,memWrite,memtoreg,memRead,regDst,branch,zero,PCsrc,jump;
wire 		 flushIF,nop;

always@(posedge Rst) 
	begin 
		PC_reg= 32'd0;
		IF_ID_pipereg <= 64'd0;
		ID_EX_pipereg <=186'd0;
		EX_MEM_pipereg<=108'd0;
		MEM_WB_pipereg<= 71'd0;
  	end

// Stall signal for 5 stages : [4]:MEM_WB,[3]:EX_MEM,[2]:ID_EX,[1]:IF_ID,[0]:PC
// 	HazardUnit HazUnit (nop,stall,flushIF,MEM_WB_pipereg,EX_MEM_pipereg,ID_EX_pipereg);

always @(posedge Clk)
 	begin
 		if(stall[0]==1'b0)
			PC_reg	<= PCin ;
		else
			PC_reg	<= PC_reg;
end

//----------------------------------Instruction---Fetch---------------------------------------------------------------------------------------------------
//				Pipeline register of ex/mem stage will provide Offset_add and PCselection signal 
assign PCout=PC_reg;

	Mux 					PCSelect 			(PCin,inc4_PC,EX_MEM_pipereg[31:0],PCsrc);					// Selection musx for PC value PC+4 or PC+4+Offset
	InstructionMemoryFile 	InstructionMemory 	(PC_reg,Instruction,Clk);
	Add 			  		PCAddressIncrement	(inc4_PC,PCout,32'd4);								// Adder for PC + 4

always@(posedge Clk)
	begin 
		if(stall[1]==1'b0)
		 begin
			IF_ID_pipereg[31: 0] <= Instruction;
			IF_ID_pipereg[63:32] <= inc4_PC;
		 end
		else
			IF_ID_pipereg		 <= IF_ID_pipereg;
	end

//----------------------------------Instruction---Decode---------------------------------------------------------------------------------------------------
// Control Unit generates only 2 bits of ALU op that go to ALUControl in Next Stage.

assign rsSel  = IF_ID_pipereg[25:21];   // Instruction's Rs Field
assign rtSel  = IF_ID_pipereg[20:16];	//	Instruction's Rt Field
assign rdSel  = IF_ID_pipereg[15:11];	//	Instruction's Rd Field
assign opCode = IF_ID_pipereg[31:26];
assign JuOffset32={IF_ID_pipereg[63:60],JuOffset28};  										// {PC+4[31:28], 28 bit shiftet jump address}
assign ControlWire1	={ALUsrc,regWrite,memWrite,ALUOp,memtoreg,memRead,regDst,branch,jump};  // Control Signals Bundled together.

	RegisterFile		Registers 			(data1,data2,rsSel,rtSel,MEM_WB_pipereg[68:64],writeData,Clk,Rst,MEM_WB_pipereg[70]);	// General Purpose Register File 32 GPRs
	SignExt 			SignExtend 			(Extdata,IF_ID_pipereg[15:0]);			// Sign Extends Immediate value to 32 bits
	Control 			CUnit 				(opCode_nop,ALUsrc,regWrite,memWrite,ALUOp,memtoreg,memRead,regDst,branch,jump);			//Control decodes all the control signals
	Shft2Jump 			Shiftby2Jump		(JuOffset28,IF_ID_pipereg[25:0]);		// 26 bit jump offset left shifted by 2 
	Mux6 				NOPinsert 			(opCode_nop,opCode,6'b111111,nop); 
										//	(nop,stall,flushIF,	EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rt,ID_EX_Rs,EX_MEM_regWen,MEM_WB_regWen);
	HazardUnit 			HazUnit 			(nop,stall,flushIF,writeReg,writeReg2,rtSel ,rsSel  ,ControlWire2[5],ControlWire3[1]);

always@(posedge Clk)
	begin 
		if(stall[2]==1'b0 && nop==1'b0)
		 begin
			ID_EX_pipereg[ 31:  0] <= data1;					// Rs 32 bit data
			ID_EX_pipereg[ 63: 32] <= data2;					// Rt 32 bit data
			ID_EX_pipereg[ 95: 64] <= Extdata;					//Immediate Sign extended value
			ID_EX_pipereg[105: 96] <={rtSel,rdSel};				// Rt and Rd for writeback stage
			ID_EX_pipereg[115:106] <=ControlWire1;				// Control wire1= {ALUsrc,regwrite,memwrite,ALUop1,ALUop0,memtoreg,memread,regdst,branch,jump} [115:106]
			ID_EX_pipereg[147:116] <=IF_ID_pipereg[63:32];		// Forwards the PC+4 Address
			ID_EX_pipereg[153:148] <=opCode_nop;					// Forwards Opcode for Immeddiate type Decoding to be used by ALUControl
			ID_EX_pipereg[185:154] <=JuOffset32;				// Jump Offset= {4 higher bits of PC+4, 28 bits of left shifted 26 bit Jump offset immediate  }
			ID_EX_pipereg[190:186] <=rsSel;
		 end
		else
			ID_EX_pipereg			<={JuOffset32,opCode_nop,ID_EX_pipereg[147:116],116'h1_5000_0000_0000_0000_0000_0000_0000};
		//	ID_EX_pipereg			<=ID_EX_pipereg;
	end

//----------------------------------EXECUTION STAGE-----------------------------------------------------------------------------------------------------------
					
assign ControlWire2={ID_EX_pipereg[106],ID_EX_pipereg[114:113],ID_EX_pipereg[110:109],ID_EX_pipereg[107],zero};	   //  	jump,-,regWrite,memWrite,--,memtoreg,memRead,-,branch,Zero

	ALU 			ALU0 					(Zero,ALUresult,ID_EX_pipereg[31:0],B,ALUCnt);		
	ALUControl 		ALU1 					(ALUCnt,ID_EX_pipereg[112:111],ID_EX_pipereg[69:64],ID_EX_pipereg[153:148]);// 2 Bits of ALUOp, 6 bits for I-Type OP
	Mux 			InputSelectALU 			(B,ID_EX_pipereg[63:32],ID_EX_pipereg[95:64],ID_EX_pipereg[115]); 			// [115] is AluSrc 
	Shft2 			Shiftby2 				(ImOffset,ID_EX_pipereg[95:64]);
	Add  			ImmediateAddressAdder	(Offset_add,ID_EX_pipereg[147:116],ImOffset);								//Adder for adding Immediate Offset to PC + 4
	Mux5 			RdRtSelRF 				(writeReg,ID_EX_pipereg[105:101],ID_EX_pipereg[100:96],ID_EX_pipereg[108]); //Reg Dst 	
	Mux 			JumpAddressSel 			(JA_ALUout,ALUresult,ID_EX_pipereg[185:154],ID_EX_pipereg[106]); 			// [106] = JUMP

always@(posedge Clk)
	begin
		if(stall[3]==1'b0)
		begin
			EX_MEM_pipereg[ 31:  0] <= Offset_add;			// PC immediate offset address
			EX_MEM_pipereg[ 63: 32] <= JA_ALUout;			// Alu output or Jump address depends on Jump signal
			EX_MEM_pipereg[ 95: 64] <= ID_EX_pipereg[63:32]; // Data 2 from Register File
			EX_MEM_pipereg[102: 96] <= ControlWire2;		// Control wire2 = {jump,regwrite,memwrite,memtoreg,memread,branch,zero} [102: 96]
			EX_MEM_pipereg[107:103] <= writeReg;			// Register to be selected in writeback stage either rs or rt
		end
		else
			EX_MEM_pipereg			<=EX_MEM_pipereg;
	end
	
//----------------------------------MEMORY STAGE-----------------------------------------------------------------------------------------------------------

assign ControlWire3 = {EX_MEM_pipereg[101],EX_MEM_pipereg[99]}; // regWrite, memtoreg
assign PCsrc 	 	=  EX_MEM_pipereg[102] | (EX_MEM_pipereg[ 97] & EX_MEM_pipereg[96]); // pcSrc= (branch & zero)|Jump 
assign writeReg2    =  EX_MEM_pipereg[107:103];
DataMemoryFile 			DataMemory 				(DO,EX_MEM_pipereg[63:32],EX_MEM_pipereg[95:64],EX_MEM_pipereg[100],EX_MEM_pipereg[98],Clk,Rst);

always@(posedge Clk)
	begin
		if(stall[4]==1'b0)
		begin
			MEM_WB_pipereg[ 31:  0]  <= DO;						// Memory read Data
			MEM_WB_pipereg[ 63: 32]  <= EX_MEM_pipereg[ 63: 32];	// ALU output
			MEM_WB_pipereg[ 68: 64]  <= writeReg2;  // Writeback register Select 
			MEM_WB_pipereg[ 70: 69]  <= ControlWire3;			// regWrite, memtoreg
		end
		else
			MEM_WB_pipereg			<=MEM_WB_pipereg;
	end

//----------------------------------WRITEBACK STAGE--------------------------------------------------------------------------------------------------------------------

Mux 					MemorySelMux 			(writeData,MEM_WB_pipereg[31:0],MEM_WB_pipereg[63:32],MEM_WB_pipereg[69]);

endmodule