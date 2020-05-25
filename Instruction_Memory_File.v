module Instruction_Memory_File(Address,Data,Wen,Clk,Rst);
	input [31:0] Address;
	output      [31:0] Data;
	input 	    	  Clk,Wen,Rst;

	reg        [31:0] registerbank [0:31];

	always @(posedge Clk) 
	begin
		if(~Rst) 
			begin
			 	registerbank[ 0]<= 32'd0;
			 	registerbank[ 1]<= 32'd0;
			 	registerbank[ 2]<= 32'd0;
			 	registerbank[ 3]<= 32'd0;
			 	registerbank[ 4]<= 32'd0;
			 	registerbank[ 5]<= 32'd0;
			 	registerbank[ 6]<= 32'd0;
			 	registerbank[ 7]<= 32'd0;
			 	registerbank[ 8]<= 32'd0;
			 	registerbank[ 9]<= 32'd0;
			 	registerbank[10]<= 32'd0;
			 	registerbank[11]<= 32'd0;
			 	registerbank[12]<= 32'd0;
			 	registerbank[13]<= 32'd0;
			 	registerbank[14]<= 32'd0;
			 	registerbank[15]<= 32'd0;
			 	registerbank[16]<= 32'd0;
			 	registerbank[17]<= 32'd0;
			 	registerbank[18]<= 32'd0;
			 	registerbank[19]<= 32'd0;
			 	registerbank[20]<= 32'd0;
			 	registerbank[21]<= 32'd0;
			 	registerbank[22]<= 32'd0;
			 	registerbank[23]<= 32'd0;
			 	registerbank[24]<= 32'd0;
			 	registerbank[25]<= 32'd0;
			 	registerbank[26]<= 32'd0;
			 	registerbank[27]<= 32'd0;
			 	registerbank[28]<= 32'd0;
			 	registerbank[29]<= 32'd0;
			 	registerbank[30]<= 32'd0;
			 	registerbank[31]<= 32'd0;			 
			 end
	end
	

	assign Data = registerbank[Address] ;

	always @(posedge Clk) 
	begin
		if(Wen)
			registerbank[Address] <= Data;
	end
endmodule
