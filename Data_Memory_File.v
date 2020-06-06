module DataMemoryFile(MemError,ReadData,Address,WriteData,memWrite,memRead,Clk,Rst);
	output      [31:0] ReadData;
	output			   MemError;

	input [31:0] Address;
	input [31:0] WriteData;
	input 	     Clk,memWrite,memRead,Rst;

	reg        [7:0] dataMem [0:63];  //8x64 Bits = 64 Byte memory

	initial begin $readmemh("Data_Memory.txt",dataMem); end

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
	

	assign ReadData =(memRead)?{dataMem[Address+2'b11],dataMem[Address+2'b10],dataMem[Address+2'b01],dataMem[Address]}:32'hZZZZZZZZ;
				// Scoops 4 8 bit memory locations at a time in Little Endian
	always @(posedge Clk) 
	begin
		if(memWrite)
			{dataMem[Address+2'b11],dataMem[Address+2'b10],dataMem[Address+2'b01],dataMem[Address]} <= WriteData;
			// Writes 4 bytes
	end
endmodule
