module EqualityDetector(zero_eqdet,data1,data2);

	output reg zero_eqdet;
	input [31:0] data1,data2;

	always @(data1,data2)
	 begin
	 	zero_eqdet= ~(|(data1^data2));
	 end
endmodule
