module tiles(input Reset, vs, pixel_clk, blank,
					input [7:0] keycode,
               input [9:0]  DrawX, DrawY,
					output [3:0] red, green, blue);
					
logic [4:0] tiles [4];
logic [2:0] col;
logic [1:0] row;
logic isBlack, isGray, isSelected, isReady;
logic isError1, first;
logic [2:0] selectedTile;
logic [3:0] scroll;
logic [6:0] count = 7'b0000000;
logic [4:0] incoming;
logic signed [10:0] newDrawY;
logic [2:0] random;
logic [5:0] iterations;
logic [7:0] keycode_mem;
logic [2:0] speedCounter;
logic [4:0] nextSpeed;
//
//logic[10:0] fontRomNth, fontRomFinalRow;
//logic[7:0] fontRomOutput;
logic isStartText, isD, isF, isJ, isK, isSpace, isEnd;
logic [6:0]startTextVec[5];

assign startTextVec[0] = 83;
assign startTextVec[1] = 116;
assign startTextVec[2] = 97;
assign startTextVec[3] = 114;
assign startTextVec[4] = 116;

LFSR #(.NUM_BITS(3)) LFSR0(
	 .i_Clk(vs),
	 .i_Enable(1'b1),
	 .i_Seed_DV(1'b0),
	 .i_Seed_Data(3'b0), // Replication
	 .o_LFSR_Data(random),
	 .o_LFSR_Done()
);

//font_rom f0 (
//	.addr(fontRomFinalRow),
//	.data(fontRomOutput)
//);

text #(.NUM_CHAR(5)) start0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(152),
.StartY(404),
.textVec(startTextVec),
.scale(2),
.isText(isStartText)
);

//====================================================================

text #(.NUM_CHAR(1)) d0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(48),
.StartY(388),
.textVec('{68}),
.scale(4),
.isText(isD)
);

text #(.NUM_CHAR(1)) f0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(176),
.StartY(388),
.textVec('{70}),
.scale(4),
.isText(isF)
);

text #(.NUM_CHAR(1)) space0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(304),
.StartY(388),
.textVec('{22}),
.scale(4),
.isText(isSpace)
);

text #(.NUM_CHAR(1)) j0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(432),
.StartY(388),
.textVec('{74}),
.scale(4),
.isText(isJ)
);

text #(.NUM_CHAR(1)) k0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(560),
.StartY(388),
.textVec('{75}),
.scale(4),
.isText(isK)
); 

text #(.NUM_CHAR(10)) end0(
.DrawX(DrawX),
.DrawY(DrawY),
.StartX(0),
.StartY(128),
.textVec('{71, 65, 77, 69, 0, 79, 86, 69, 82, 33}),
.scale(8),
.isText(isEnd)
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
						isError1 = 0;
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
					
				default: begin
					isSelected = 0;
					isError1 = 0;
					end
			endcase
				
			isBlack = tiles[row][col];
		end
		else begin
			isBlack = tiles[row][col];
			isSelected = 0;
			isError1 = 0;
		end
		
	end
	
	//isGray = DrawX % 128 == 0 || DrawX % 128 == 127 || newDrawY % 120 == 0 || newDrawY % 120 == 119;
	isGray = DrawX % 128 == 0 || DrawX % 128 == 127;
	
//	fontRomNth = startTextVec[(DrawX - 152) >> 4];
//	fontRomFinalRow = (fontRomNth << 4) + ((DrawY -  404) >> 1);
//	//fontRomFinalRow = 18;
//	
//	if (DrawX <= 231 && DrawX >= 152 && DrawY >= 404 && DrawY <= 435) begin
//		isStartText = fontRomOutput[7 - (((DrawX - 152) >> 1) % 8)];
//		//isStartText = fontRomOutput[5];
//	end
//	else begin
//		isStartText = 0;
//	end
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
		speedCounter <= 2;
		nextSpeed <= 1;
		first <= 1;
		keycode_mem <= 0;
		iterations <= 5;
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
		if (isReady) begin
			scroll <= 0;
		end
		else begin
			scroll <= nextSpeed;
		end
		isReady <= 1;
		
		if (speedCounter == iterations) begin
			if (nextSpeed == 1) begin
				nextSpeed <= 2;
			end
			else if (nextSpeed == 12) begin
				nextSpeed <=12;
			end
			else begin
				nextSpeed <= nextSpeed + 2;
			end
			speedCounter <= 1;
			iterations = nextSpeed * 5;
		end
		
		else begin
			speedCounter <= speedCounter + 1;
		end
		//isError1 <= 0;
	end
	
	else if (isError1 == 1) begin
		scroll <= 0;
	end
	else begin
		if (isReady && keycode != 0) begin
			keycode_mem <= keycode;
			isReady <= 0;
			//isError1 <= 0;
			if (first) begin
			scroll <= nextSpeed;
			first <=0;
			end
		end
		count <= count + scroll;
	end

end

//always_ff @(posedge Reset or posedge pixel_clk) begin
//	if (Reset) begin
//		speedCounter <= 0;
//		nextSpeed <= 1;
//	end 
//	
//	else if (speedCounter == 249999999) begin
//		//scrollAddition
//		
//		if (nextSpeed == 1) begin
//			nextSpeed <= 2;
//		end
//		else if (nextSpeed == 12) begin
//			nextSpeed <=12;
//		end
//		else begin
//			nextSpeed <= nextSpeed + 2;
//		end
//		speedCounter <= 0;
//	end
//	else begin
//		speedCounter <= speedCounter + 1;
//	end
//	
//end

//assign scroll = ~isError1 && isReady;


always_ff @(posedge pixel_clk) begin

	if (!blank)
	begin
		red <= 4'b0000;
		green <= 4'b0000;
		blue <= 4'b0000;
	end
	else if (!scroll && !first && isEnd == 1'b1)
	begin
		red <= 4'b1111;
		blue <= 4'b1111;
		green <= 4'b0000;
	end
	else if (!scroll && (isSpace == 1'b1 || isD == 1'b1 || isF == 1'b1 || isK == 1'b1 || isJ == 1'b1))
	begin
		green <= 4'b1111;
		red <= 4'b0000;
		blue <= 4'b0000;
	end
	else if (first && isStartText == 1'b1)
	begin
		red <= 4'b0000;
		blue <= 4'b1111;
		green <= 4'b0000;
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