/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  presentRam
(
		input [4:0] data_In,
		input [13:0] write_address, read_address,
		input [2:0] cs,
		input we, Clk,

		output logic [2:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [2:0] mem1 [11664];
logic [2:0] mem2 [11664];
logic [2:0] mem3 [11664];
logic [2:0] mem4 [11664];
logic [2:0] mem5 [11664];
logic [2:0] mem6 [11664];

initial
begin
	 $readmemh("present1.txt", mem1);
	 $readmemh("present2.txt", mem2);
	 $readmemh("present3.txt", mem3);
	 $readmemh("present4.txt", mem4);
	 $readmemh("present5.txt", mem5);
	 $readmemh("present6.txt", mem6);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem1[write_address] <= data_In;
		
	case(cs)
	0: data_Out<= mem1[read_address];
	1: data_Out<= mem2[read_address];
	2: data_Out<= mem3[read_address];
	3: data_Out<= mem4[read_address];
	4: data_Out<= mem5[read_address];
	5: data_Out<= mem6[read_address];
	default: ;
	endcase
	
end

endmodule
