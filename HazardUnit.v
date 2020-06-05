module HazardUnit(nop,stall,flush,branch,jump,EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rt,ID_EX_Rs,EX_MEM_regWen,ID_EX_memRead,MEM_WB_regWen,Rst);

	output reg 	[3:0]	stall;  // Stall signal for 5 stages : [3]:EX_MEM,[2]:ID_EX,[1]:IF_ID,[0]:PC
	output 			flush; // flush empties the fetched instruction,Nop deasserts the control signals.
	output reg          nop;

	input 		[4:0] 	EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rs,ID_EX_Rt;
	input       		EX_MEM_regWen,MEM_WB_regWen,ID_EX_memRead;
	input 				Rst,branch,jump;

	reg Hazflag;					// Flag register for DEBUGGING

	assign flush=branch||jump;

always@(negedge Rst)
	begin
	 stall 	 	=4'b0000;
	 Hazflag	=1'b0;
//	 flush 		=1'b0;
	end

always@(*)
	begin
		if(EX_MEM_regWen && ((EX_MEM_Rd != 5'd0))) // Check  EX Hazard
		begin
			if((EX_MEM_Rd==ID_EX_Rs)||(EX_MEM_Rd==ID_EX_Rt))
			begin
		 		stall[0]	<= 1'b1; 	//PC
		 		stall[1]	<= 1'b1;	//IF_ID
		 		stall[2]	<= 1'b0;	//ID_EX
		 		stall[3]	<= 1'b0;	//EX_MEM
//		 		flush 		<= 1'b0;
		 		Hazflag		<= 1'b1;
		 		nop 		<= 1'b1;
			end
		end
			// Hazard for dependency in ID and MEM stage
		else if(MEM_WB_regWen && ((MEM_WB_Rd != 5'd0)))
		begin
			if((MEM_WB_Rd==ID_EX_Rs)||(MEM_WB_Rd==ID_EX_Rt))
			begin
		 		stall[0]	<= 1'b1; 	//PC
		 		stall[1]	<= 1'b1;	//IF_ID
		 		stall[2]	<= 1'b0;	//ID_EX
		 		stall[3]	<= 1'b0;	//EX_MEM
//		 		flush 		<= 1'b0;
		 		Hazflag		<= 1'b1;
		 		nop 		<= 1'b1;
			end
		end
					// Load after a Store
		else if(ID_EX_memRead && ((MEM_WB_Rd != 5'd0)))
		begin
			if((EX_MEM_Rd==ID_EX_Rs)||(EX_MEM_Rd==ID_EX_Rt))
			begin
				stall[0]	<= 1'b1; 	//PC
		 		stall[1]	<= 1'b1;	//IF_ID
		 		stall[2]	<= 1'b0;	//ID_EX
		 		stall[3]	<= 1'b0;	//EX_MEM
//		 		flush 		<= 1'b0;
		 		Hazflag		<= 1'b1;
		 		nop 		<= 1'b1;
			end 
		end
					//Hazard if a branch/jump is to be carried out 
		else
			begin
		 		stall[0]	<= 1'b0; 	//PC
		 		stall[1]	<= 1'b0;	//IF_ID
		 		stall[2]	<= 1'b0;	//ID_EX
		 		stall[3]	<= 1'b0;	//EX_MEM
//		 		flush 		<= 1'b0;
		 		Hazflag		<= 1'b0;
		 		nop 		<= 1'b0;
			end
	end  
endmodule

	//  Hazards :   TYPE 1    EXECUTION HAZARDS
	//		EX/MEM.REGISTER RD = =  ID/EX.REGISTER RS
	//		EX/MEM.REGISTER RD = =  ID/EX.REGISTER RT
	//  Hazards :   TYPE 2    MEMORY HAZARDS
	//		MEM/WB.REGISTER RD = =  ID/EX.REGISTER RS
	//		MEM/WB.REGISTER RD = =  ID/EX.REGISTER RT
						// 1= Stall 0= Not stall
						// Nop = 1 controls deasserted , Control encoding = 6'd63 = 6'b111111
	//
// if writing destination for one instruction after execution is same as reading source of consequent instruction. 
// Also checking if the regiter write control is active or not.
// Hazard occurs only if execution writes to register.