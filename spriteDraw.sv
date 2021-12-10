module present(
	input [9:0] DrawX, DrawY, StartX, StartY,
	input logic Clk,
	input [3:0] cs,
	input logic randomColor,
	output [3:0] Red, Green, Blue,
	output logic show

);

	logic [2:0] ramOut;
	logic [13:0] ramAddress; 

	presentRam (
	
		.data_In(),
		.write_address(),
		.read_address(ramAddress),
		.we(0),
		.Clk(Clk),
		.data_Out(ramOut),
		.cs(cs/3)
	
	);
	
	logic [11:0] colorPalette [5];
	assign colorPalette[0] = 12'hf00;
	assign colorPalette[1] = 12'h0f0;
	assign colorPalette[2] = 12'h000;
	
	always_comb begin
		if (randomColor) begin
			colorPalette[3] = 12'hAF0;
		end
		else begin
			colorPalette[3] = 12'h0FF;
		end
	end
	
	assign colorPalette[4] = 12'hFFF;
	

	always_comb begin
		ramAddress = (108 * (DrawY - StartY) + (DrawX - StartX));
		Red = colorPalette[ramOut][11:8];
		Green = colorPalette[ramOut][7:4];
		Blue = colorPalette[ramOut][3:0];
		
		show = DrawX >= (StartX) && DrawX <= (StartX + 107) && DrawY >= StartY && DrawY <= (StartY + 107);
	end




endmodule