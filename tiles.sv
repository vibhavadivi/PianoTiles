module tiles(input Reset, vs, pixel_clk, blank,
					input [7:0] keycode,
               input [9:0]  DrawX, DrawY,
					output [3:0] red, green, blue);
					
logic [4:0] tiles [4];
logic [2:0] col;
logic [1:0] row;
logic isBlack, isGray, isSelected, isReady;
logic scroll, isError1;
logic [2:0] selectedTile;

logic [6:0] count = 7'b0000000;
logic [4:0] incoming;
logic signed [10:0] newDrawY;
logic [2:0] random;

logic [7:0] keycode_mem;


LFSR #(.NUM_BITS(3)) LFSR0(
	 .i_Clk(vs),
	 .i_Enable(1'b1),
	 .i_Seed_DV(1'b0),
	 .i_Seed_Data(3'b0), // Replication
	 .o_LFSR_Data(random),
	 .o_LFSR_Done()
);

always_comb begin
	col = DrawX >> 7;
	
	newDrawY = DrawY - count;
	
	if (newDrawY < 0)
	begin
		isBlack = incoming[col];
		row = 0;
		isSelected = 0;
		isError1 = 0;
	end
	
	else begin
		row = newDrawY / 120;
		if (row == 3 && keycode_mem != 0) 
		begin
			case(tiles[3])
				5'b10000:  //K
					if (keycode_mem == 8'h0e && col == 4) begin
						isSelected = 1;
						isError1 = 0;
					end
					else if (keycode_mem != 8'h0e) begin
						isSelected = 0;
						isError1 = 1;
					end
					else begin
						isSelected = 0;
						isError1 = 0;
					end
					
				5'b01000: //J
					if (keycode_mem == 8'h0d && col == 3) begin
						isSelected = 1;
						isError1 = 0;
					end
					else if (keycode_mem != 8'h0d) begin
						isSelected = 0;
						isError1 = 1;
					end
					else begin
						isSelected = 0;
						isError1 = 0;	
					end
					
				5'b00100: //SPACE
					if (keycode_mem == 8'h2c && col == 2) begin
						isSelected = 1;
						isError1 = 0;
					end
					else if (keycode_mem != 8'h2c) begin
						isSelected = 0;
						isError1 = 1;
					end
					else begin
						isSelected = 0;
						isError1 = 0;	
					end
					
				5'b00010: //F
					if (keycode_mem == 8'h09 && col == 1) begin
						isSelected = 1;
						isError = 0;
					end
					else if (keycode_mem != 8'h09) begin
						isSelected = 0;
						isError1 = 1;
					end
					else begin
						isSelected = 0;
						isError1 = 0;	
					end
					
				5'b00001: //D
					if (keycode_mem == 8'h07 && col == 0) begin
						isSelected = 1;
						isError1 = 0;
					end
					else if (keycode_mem != 8'h07) begin
						isSelected = 0;
						isError1 = 1;
					end
					else begin
						isSelected = 0;
						isError1 = 0; 
					end
					
				default: 
					isSelected = 0;
					isError1 = 0;
			endcase
				
			isBlack = tiles[row][col];
		end
		else begin
			isBlack = tiles[row][col];
			isSelected = 0;
		end
		
	end
	
	isGray = DrawX % 128 == 0 || DrawX % 128 == 127 || newDrawY % 120 == 0 || newDrawY % 120 == 119;
end

always_ff @(posedge Reset or posedge vs) begin
	if (Reset)
	begin
		tiles[0] <= 5'b10000;
		tiles[1] <= 5'b01000;
		tiles[2] <= 5'b00100;
		tiles[3] <= 5'b00010;
		count <= 0;
		incoming <= 5'b00001;
		isReady <= 1;
		scroll <= 0;
	end
	else if (count == 7'b1111000)
	begin
		tiles[0] <= incoming;
		count <= 0;
		incoming <= 1'b1 << (random%5);
		tiles[3] <= tiles[2];
		tiles[2] <= tiles[1];
		tiles[1] <= tiles[0];
		keycode_mem <= 0;
		//if (isReady) begin
			//scroll <= 0;
		//end
		isReady <= 1;
		//isError1 <= 0;
		
	end
	else begin
		if (isReady && keycode != 0) begin
			keycode_mem <= keycode;
			isReady <= 0;
			//isError1 <= 0;
			//scroll <= 1;
		end
		count <= count + scroll;
	end

end

assign scroll = !isError && isReady;


always_ff @(posedge pixel_clk) begin

	if (!blank)
	begin
		red <= 4'b0000;
		green <= 4'b0000;
		blue <= 4'b0000;
	end
	else if (isGray == 1'b1) 
	begin
		red <= 4'b1000;
		green <= 4'b1000;
		blue <= 4'b1000;
	end
	else if (isSelected == 1'b1)
	begin
		red <= 4'b1111;
		green <= 4'b0000;
		blue <= 4'b0000;
	end
	else if (isBlack == 1'b1)
	begin
		red <= 4'b0000;
		green <= 4'b0000;
		blue <= 4'b0000;
	end
	else
	begin
		red <= 4'b1111;
		green <= 4'b1111;
		blue <= 4'b1111;
	end
end

endmodule