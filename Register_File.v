module RegisterFile(data1,data2,read1,read2,writeReg,writeData,Clk,Rst,regWen);
	output      [31:0] data1,data2;
	input 		[31:0] writeData;
	input      	[ 4:0] read1,read2,writeReg;
	input 	    	  Clk,regWen,Rst;

	reg       	 [31:0] registerbank [0:31];

	always @(posedge Clk) 
	begin
		if(~Rst) 
			begin
			 	$readmemh("Register_File.txt",registerbank);
			 end
	end
	

	assign data1 = registerbank[read1] ;
	assign data2 = registerbank[read2];

	always @(negedge Clk) 
	begin
			registerbank[0] <= 32'd0;
		if(regWen)
			registerbank[writeReg] <= writeData;
	end
endmodule
