module HazardUnit(nop,stall,flushIF,EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rt,ID_EX_Rs,EX_MEM_regWen,MEM_WB_regWen,Rst);

	output reg 	[4:0]	stall;  // Stall signal for 5 stages : [4]:MEM_WB,[3]:EX_MEM,[2]:ID_EX,[1]:IF_ID,[0]:PC
	output reg			flushIF; // flushIF empties the fetched instruction,Nop deasserts the control signals.
	output reg          nop;
	input 		[4:0] 	EX_MEM_Rd,MEM_WB_Rd,ID_EX_Rs,ID_EX_Rt;
	input       		EX_MEM_regWen,MEM_WB_regWen;
	input 				Rst;

	reg Hazflag;					// Flag register for DEBUGGING

always@(posedge Rst)
	begin
	 stall = 5'b00000;
	 nop=1'b0;
	 Hazflag=1'b0;
	end

always@(*)
	begin

		if(EX_MEM_regWen && ((EX_MEM_Rd != 5'd0))) // Check for regWen==1 EX Hazard
		begin
			if((EX_MEM_Rd==ID_EX_Rs)||(EX_MEM_Rd==ID_EX_Rt))
			begin
		 		stall <= 5'b00111;   //	stall execution stage till writeback of previous instruction
				nop   <= 1'b1;
				Hazflag <= 1'b1;
			end
		end

		else if(MEM_WB_regWen && ((MEM_WB_Rd != 5'd0)))
		begin
			if((MEM_WB_Rd==ID_EX_Rs)||(MEM_WB_Rd==ID_EX_Rt))
			begin
				stall <= 5'b00111;//stall execution stage till writeback of previous instruction
				nop   <= 1'b1;
				Hazflag <= 1'b1;
			end 
		end
			else
			begin
				stall <= 5'b00000; 
				nop   <= 1'b0;
				Hazflag <= 1'b0;
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