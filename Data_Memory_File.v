module Data_Memory_File(ReadData,Address,WriteData,memWrite,Clk,Rst);
	output      [31:0] ReadData;

	input [31:0] Address;
	input [31:0] WriteData;
	input 	     Clk,memWrite,Rst;

	reg        [31:0] registerbank [0:1023];  //32x1024 Bits = 32kB memory

	initial begin $readmemh("Data_Memory.txt",registerbank); end

	// always @(posedge Clk) 
	// begin
	// 	if(~Rst) 
	// 		begin
	// 			for (i = 0; i < 1024; i=i+1) 
	// 			begin
	// 				registerbank[i] <= 32'd0;			/* Reset Memory */
	// 			end
			 	 
	// 		 end
	// end 
	

	assign ReadData = registerbank[Address] ;

	always @(posedge Clk) 
	begin
		if(memWrite)
			registerbank[Address] <= WriteData;
	end
endmodule
