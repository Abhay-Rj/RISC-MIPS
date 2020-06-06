module HazardUnit(hazType,branch,jump,EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rt,ID_EX_Rs,EX_MEM_regWen,ID_EX_memRead,MEM_WB_regWen);

//		type 0 : No Hazard
//		type 1 : Data Hazard : Stall IF and ID stages
//		type 2 : Control Hazard : Flush IF
//		type 3 : Cache Hazard   : Stall the  IF,ID,EX and MEM stages

	output  	[1:0]	hazType;
	input 		[4:0] 	EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rs,ID_EX_Rt;
	input       		EX_MEM_regWen,MEM_WB_regWen,ID_EX_memRead;
	input 				branch,jump;

	reg hazFlag,stall,flush;					// Flag register for DEBUGGING

assign hazType={flush,stall};

always@(*)
	begin
						// Hazard for Branch /Jump stage
		if(branch||jump)
			begin
				flush 	<= 1'b1;
				hazFlag <= 1'b1;
			end
		else
			begin
				flush 	<= 1'b0;
				hazFlag <= 1'b0;
			end
		// Hazard for dependency in ID and EX stage
		if(EX_MEM_regWen && ((EX_MEM_Rd != 5'd0)))
		begin
			if((EX_MEM_Rd==ID_EX_Rs)||(EX_MEM_Rd==ID_EX_Rt))
			begin
				stall 	<= 1'b1;
				hazFlag <= 1'b1;
			end
		end
			// Hazard for dependency in ID and MEM stage
		else if(MEM_WB_regWen && ((MEM_WB_Rd != 5'd0)))
		begin
			if((MEM_WB_Rd==ID_EX_Rs)||(MEM_WB_Rd==ID_EX_Rt))
			begin
				stall 	<= 1'b1;
				hazFlag <= 1'b1;
			end
		end
					// Load after a Store
		else if(ID_EX_memRead && ((MEM_WB_Rd != 5'd0)))
		begin
			if((EX_MEM_Rd==ID_EX_Rs)||(EX_MEM_Rd==ID_EX_Rt))
			begin
				stall 	<= 1'b1;
				hazFlag <= 1'b1;
			end 
		end

		else
			begin
		 		stall  <= 1'b0; //Type 0
		 		flush 	<= 1'b0;
				hazFlag<= 1'b0;
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