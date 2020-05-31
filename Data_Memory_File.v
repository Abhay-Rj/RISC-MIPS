module DataMemoryFile(ReadData,Address,WriteData,memWrite,memRead,Clk,Rst);
	output      [31:0] ReadData;

	input [31:0] Address;
	input [31:0] WriteData;
	input 	     Clk,memWrite,memRead,Rst;

	reg        [7:0] registerbank [0:63];  //8x64 Bits = 64 Byte memory

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
	

	assign ReadData =(memRead)?{registerbank[Address+2'b11],registerbank[Address+2'b10],registerbank[Address+2'b01],registerbank[Address]}:32'hZZZZZZZZ;
				// Scoops 4 8 bit memory locations at a time in Little Endian
	always @(posedge Clk) 
	begin
		if(memWrite)
			{registerbank[Address+2'b11],registerbank[Address+2'b10],registerbank[Address+2'b01],registerbank[Address]} <= WriteData;
			// Check again Not sure yet
	end
endmodule
