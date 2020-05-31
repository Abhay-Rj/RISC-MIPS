module InstructionMemoryFile(Address,Data,Clk);
	input [31:0] Address;
	output      [31:0] Data;
	input 	    	  Clk,Rst;

	reg        [ 7:0] imembank [0:63];  //  8x64  64B memory

initial begin $readmemh("Instruction_Memory.txt",imembank); end


	// always @(posedge Clk) 
	// begin
	// 	if(~Rst) 
	// 		for (int i = 0; i <64; i++) 
	// 			begin
	// 				imembank[i]<= 32'd0;			/* Reset Memory */
	// 			end
	// end
	

	assign Data = {imembank[Address+3'b11],imembank[Address+2'b10],imembank[Address+2'b01],imembank[Address]} ;

endmodule
