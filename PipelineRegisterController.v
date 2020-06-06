module pipeRegControl(nop,stall,flush,hazType);
	
	output 	reg 	[3:0] 	stall;
	output 	reg 			nop,flush;

	input 			[1:0]	 hazType;

always@(*)
	begin 

		case (hazType)

			2'b00:	// No Hazard
				begin
					nop 		<= 1'b0;
					flush		<= 1'b0;
					stall[0]	<= 1'b0; 	//PC
		 			stall[1]	<= 1'b0;	//IF_ID
		 			stall[2]	<= 1'b0;	//ID_EX
		 			stall[3]	<= 1'b0;	//EX_MEM

				end

			2'b01:	// Stall IF and ID stages , insert bubble .
				begin
					nop 		<= 1'b1;
					flush		<= 1'b0;
					stall[0]	<= 1'b1; 	//PC
		 			stall[1]	<= 1'b1;	//IF_ID
		 			stall[2]	<= 1'b0;	//ID_EX
		 			stall[3]	<= 1'b0;	//EX_MEM
		 		end
			2'b10:	// Branch Jump Hazard, Flush the IF/IF register, 
				begin
					nop 		<= 1'b0;
					flush		<= 1'b1;
					stall[0]	<= 1'b0; 	//PC
		 			stall[1]	<= 1'b0;	//IF_ID
		 			stall[2]	<= 1'b0;	//ID_EX
		 			stall[3]	<= 1'b0;	//EX_MEM

				end

			2'b01:	// Stall IF,ID,EX,MEM , no bubble.
				begin
					nop 		<= 1'b0;
					flush		<= 1'b0;
					stall[0]	<= 1'b1; 	//PC
		 			stall[1]	<= 1'b1;	//IF_ID
		 			stall[2]	<= 1'b1;	//ID_EX
		 			stall[3]	<= 1'b1;	//EX_MEM
		 		end

			default : // Normal
				begin
					nop 		<= 1'b0;
					flush		<= 1'b0;
					stall[0]	<= 1'b0; 	//PC
		 			stall[1]	<= 1'b0;	//IF_ID
		 			stall[2]	<= 1'b0;	//ID_EX
		 			stall[3]	<= 1'b0;	//EX_MEM

				end
		endcase
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