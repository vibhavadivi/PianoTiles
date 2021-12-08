module text #(parameter NUM_CHAR)
(input logic [9:0] DrawX, DrawY, StartX, StartY,
	input logic [3:0] scale,
	input logic [6:0] textVec[NUM_CHAR],
	output isText);
	
	logic[10:0] fontRomNth, fontRomFinalRow;
logic[7:0] fontRomOutput;

logic [9:0] EndX, EndY;

assign EndX = StartX + (scale * 8 * NUM_CHAR) - 1;
assign EndY = StartY + (scale * 16) - 1;

//assign EndX = 231;
//assign EndY = 435;

font_rom f0 (
	.addr(fontRomFinalRow),
	.data(fontRomOutput)
);

always_comb
	begin
	fontRomNth = textVec[(DrawX - StartX) / (8 * scale)];
	fontRomFinalRow = (fontRomNth << 4) + ((DrawY -  StartY) / scale);
	//fontRomNth = textVec[(DrawX - StartX) >> 4];
	//fontRomFinalRow = (fontRomNth << 4) + ((DrawY -  StartY) >> 1);
	//fontRomFinalRow = 18;
	
	if (DrawX <= EndX && DrawX >= StartX && DrawY >= StartY && DrawY <= EndY) begin
		isText = fontRomOutput[7 - (((DrawX - StartX) / scale) % 8)];
		//isStartText = fontRomOutput[5];
		//isText = 0;
	end
	else begin
		isText = 0;
	end
	end
endmodule
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