///************************************************************************
//Avalon-MM Interface VGA Text mode display
//
//Register Map:
//0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
//0x258        : control register
//
//VRAM Format:
//X->
//[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
//[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]
//
//IVn = Draw inverse glyph
//CODEn = Glyph code from IBM codepage 437
//
//Control Register Format:
//[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
//[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]
//
//VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
//BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
//FGD_R/G/B = Foreground color, flipped with background when Inv bit is set
// fsd
//************************************************************************/
//`define NUM_REGS 601 //80*30 characters / 4 characters per register
//`define CTRL_REG 600 //index of control register
//
//module vga_text_avl_interface (
//	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
//	// We can put a clock divider here in the future to make this IP more generalizable
//	input logic CLK,
//	
//	// Avalon Reset Input
//	input logic RESET,
//	
//	// Avalon-MM Slave Signals
//	input  logic AVL_READ,					// Avalon-MM Read
//	input  logic AVL_WRITE,					// Avalon-MM Write
//	input  logic AVL_CS,					// Avalon-MM Chip Select
//	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
//	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
//	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
//	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
//	
//	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
//	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
//	output logic hs, vs						// VGA HS/VS
//);
//
////logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
////put other local variables here
//logic [31:0] palette [8];
//logic [9:0] DrawX, DrawY;
//logic pixel_clk, blank, sync;
//logic [11:0] nthChar;
//logic [7:0] fontRomOutput;
//logic [10:0] vramRow;
//logic vramRowIndex;
//logic [10:0] fontRomFirstRow;
//logic [10:0] fontRomFinalRow;
//logic [2:0] fontRomFinalCol;
//logic fontRomBit;
//logic [15:0] vramOutput;
//logic [2:0] paletteRowFGD, paletteRowBKG;
//logic [11:0] paletteFGD, paletteBKG;
////Declare submodules..e.g. VGA controller, ROMS, etc
//
//logic [31:0] q_b;
//
////assign palette[0] = 4'h2138;
////assign palette[5] = 4'h2538;
////assign palette[7] = 4'h2238;
//
//
//
//vga_controller v0 (
//	.Clk(CLK),
//	.Reset(RESET),
//	.hs(hs),
//	.vs(vs),
//	.pixel_clk(pixel_clk),
//	.blank(blank),
//	.sync(sync),
//	.DrawX(DrawX),
//	.DrawY(DrawY)
//);
//
//font_rom f0 (
//	.addr(fontRomFinalRow),
//	.data(fontRomOutput)
//);
//
//ram ram0 (
//	.address_a(AVL_ADDR), 
//	.address_b(vramRow),
//	.byteena_a(AVL_BYTE_EN),
//	.byteena_b(32'b0),
//	.clock(CLK),
//	.data_a(AVL_WRITEDATA),
//	.data_b(32'b0),
//	.rden_a(AVL_READ && AVL_CS),
//	.rden_b(1),
//	.wren_a(AVL_WRITE && AVL_CS && ~AVL_ADDR[11]),
//	.wren_b(0),
//	.q_a(AVL_READDATA),
//	.q_b(q_b)
//);
////a for writing to register
////b for reading from register
//
//always_ff @(posedge CLK) begin
//	if (AVL_ADDR[11] && AVL_WRITE && AVL_CS) begin
//		palette[AVL_ADDR - 12'h800] <= AVL_WRITEDATA;
//	end
//
//end
//	
//   
////// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
////always_ff @(posedge CLK) begin
////	//if (RESET) begin
////		//LOCAL_REG <= '{default:32'b0};
////	//end
////	
////	//if (AVL_WRITE && AVL_CS) begin
////	//	case (AVL_BYTE_EN)
////			//wren_a = 1'b1;
////		//endcase
////	//end
////	
////	if (AVL_READ && AVL_CS) begin
////		AVL_READDATA <= q_b;
////	end
////end
//
//always_comb begin
//
//	nthChar = 80 * (DrawY >> 4) + (DrawX >> 3);
//	vramRow = nthChar >> 1;
//	vramRowIndex = nthChar % 2;	
//	case(vramRowIndex)
//		2'b0: vramOutput = q_b[15 : 0];
//		2'b1: vramOutput = q_b[31 : 16];
//		//2'b10: vramOutput = q_b[23 : 16];
//		//2'b11: vramOutput = q_b[31 : 24];
//	endcase
//	
//	fontRomFirstRow = vramOutput[14:8]*16;
//	fontRomFinalRow = fontRomFirstRow + (DrawY % 16);
//	fontRomFinalCol = (DrawX % 8);
//	fontRomBit = fontRomOutput[7 - fontRomFinalCol];
//	
//	paletteRowFGD = vramOutput[7:4] >> 1;
//	case(vramOutput[7:4] % 2)
//		2'b0: paletteFGD = palette[paletteRowFGD][12:1];
//		2'b1: paletteFGD = palette[paletteRowFGD][24:13];
//	endcase
//	
//	paletteRowBKG = vramOutput[3:0] >> 1;
//	case(vramOutput[3:0] % 2)
//		2'b0: paletteBKG = palette[paletteRowBKG][12:1];
//		2'b1: paletteBKG = palette[paletteRowBKG][24:13];
//	endcase
//	
//	
//		
//	
//	
//		
//	
//end
//
//
//
////handle drawing (may either be combinational or sequential - or both).
//always_ff @(posedge pixel_clk) begin
//
//	if (!blank)
//	begin
//		red <= 4'b0000;
//		green <= 4'b0000;
//		blue <= 4'b0000;
//	end
//
//	else if (vramOutput[15] == 1'b1)
//	begin
//	
//		if (fontRomBit == 1'b1)  
//			begin
//				red <= paletteBKG[11:8];
//				green <= paletteBKG[7:4];
//				blue <= paletteBKG[3:0];
//			end
//			
//			else 
//			begin
//				red <= paletteFGD[11:8];
//				green <= paletteFGD[7:4];
//				blue <= paletteFGD[3:0];
//			end
//	end
//	
//	else
//	begin
//		if (fontRomBit == 1'b0)  
//			begin
//			red <= paletteBKG[11:8];
//			green <= paletteBKG[7:4];
//			blue <= paletteBKG[3:0];
//		end
//		
//		else 
//		begin
//			red <= paletteFGD[11:8];
//			green <= paletteFGD[7:4];
//			blue <= paletteFGD[3:0];
//		end
//	end
//	
//
//
//end
//
//
//
//
//
//
//		
//
//endmodule

/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set
 fsd
************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
//put other local variables here
logic [31:0] palette [8];
logic [9:0] DrawX, DrawY;
logic pixel_clk, blank, sync;
logic [11:0] nthChar;
logic [7:0] fontRomOutput;
logic [10:0] vramRow;
logic vramRowIndex;
logic [10:0] fontRomFirstRow;
logic [10:0] fontRomFinalRow;
logic [2:0] fontRomFinalCol;
logic fontRomBit;
logic [15:0] vramOutput;
logic [2:0] paletteRowFGD, paletteRowBKG;
logic [11:0] paletteFGD, paletteBKG;
//Declare submodules..e.g. VGA controller, ROMS, etc

logic [31:0] q_b;

//assign palette[0] = 4'h2138;
//assign palette[5] = 4'h2538;
//assign palette[7] = 4'h2238;

logic [4:0] tiles [4];
logic [2:0] col;
logic [1:0] row;
logic isBlack, isGray;
logic [2:0] selectedTile;

logic [6:0] count = 7'b0000000;
logic [4:0] incoming;
logic signed [10:0] newDrawY;
logic [2:0] random;

vga_controller v0 (
	.Clk(CLK),
	.Reset(RESET),
	.hs(hs),
	.vs(vs),
	.pixel_clk(pixel_clk),
	.blank(blank),
	.sync(sync),
	.DrawX(DrawX),
	.DrawY(DrawY)
);

font_rom f0 (
	.addr(fontRomFinalRow),
	.data(fontRomOutput)
);

ram ram0 (
	.address_a(AVL_ADDR), 
	.address_b(vramRow),
	.byteena_a(AVL_BYTE_EN),
	.byteena_b(32'b0),
	.clock(CLK),
	.data_a(AVL_WRITEDATA),
	.data_b(32'b0),
	.rden_a(AVL_READ && AVL_CS),
	.rden_b(1),
	.wren_a(AVL_WRITE && AVL_CS && ~AVL_ADDR[11]),
	.wren_b(0),
	.q_a(AVL_READDATA),
	.q_b(q_b)
);

LFSR #(.NUM_BITS(3)) LFSR0(
	 .i_Clk(vs),
	 .i_Enable(1'b1),
	 .i_Seed_DV(1'b0),
	 .i_Seed_Data(3'b0), // Replication
	 .o_LFSR_Data(random),
	 .o_LFSR_Done()
);
//a for writing to register
//b for reading from register

always_ff @(posedge CLK) begin
	if (AVL_ADDR[11] && AVL_WRITE && AVL_CS) begin
		palette[AVL_ADDR - 12'h800] <= AVL_WRITEDATA;
	end

end
	
	
always_comb begin
	//row = 2'b00;
	//col = 3'b000;
//	tiles[0] = 5'b10000;
//	tiles[1] = 5'b01000;
//	tiles[2] = 5'b00100;
//	tiles[3] = 5'b00010;
//	tiles[4] = 5'b00001;
//	tiles[0][$urandom_range(0,4)] = 1'b1;
//	tiles[1][$urandom_range(0,4)] = 1'b1;
//	tiles[2][$urandom_range(0,4)] = 1'b1;
//	tiles[3][$urandom_range(0,4)] = 1'b1;
end
   
//// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
//always_ff @(posedge CLK) begin
//	//if (RESET) begin
//		//LOCAL_REG <= '{default:32'b0};
//	//end
//	
//	//if (AVL_WRITE && AVL_CS) begin
//	//	case (AVL_BYTE_EN)
//			//wren_a = 1'b1;
//		//endcase
//	//end
//	
//	if (AVL_READ && AVL_CS) begin
//		AVL_READDATA <= q_b;
//	end
//end

always_comb begin

//	nthChar = 80 * (DrawY >> 4) + (DrawX >> 3);
//	vramRow = nthChar >> 1;
//	vramRowIndex = nthChar % 2;	
//	case(vramRowIndex)
//		2'b0: vramOutput = q_b[15 : 0];
//		2'b1: vramOutput = q_b[31 : 16];
//		//2'b10: vramOutput = q_b[23 : 16];
//		//2'b11: vramOutput = q_b[31 : 24];
//	endcase
//	
//	fontRomFirstRow = vramOutput[14:8]*16;
//	fontRomFinalRow = fontRomFirstRow + (DrawY % 16);
//	fontRomFinalCol = (DrawX % 8);
//	fontRomBit = fontRomOutput[7 - fontRomFinalCol];
//	
//	paletteRowFGD = vramOutput[7:4] >> 1;
//	case(vramOutput[7:4] % 2)
//		2'b0: paletteFGD = palette[paletteRowFGD][12:1];
//		2'b1: paletteFGD = palette[paletteRowFGD][24:13];
//	endcase
//	
//	paletteRowBKG = vramOutput[3:0] >> 1;
//	case(vramOutput[3:0] % 2)
//		2'b0: paletteBKG = palette[paletteRowBKG][12:1];
//		2'b1: paletteBKG = palette[paletteRowBKG][24:13];
//	endcase
	
	
	col = DrawX >> 7;
	
	newDrawY = DrawY - count;
	
	if (newDrawY < 0)
	begin
		isBlack = incoming[col];
		row = 0;
	end
	
	else begin
		row = newDrawY / 120;
		isBlack = tiles[row][col];
	end
	
	isGray = DrawX % 128 == 0 || DrawX % 128 == 127 || newDrawY % 120 == 0 || newDrawY % 120 == 119;
	
	
	
	
end


always_ff @(posedge RESET or posedge vs) begin
	if (RESET)
	begin
		tiles[0] <= 5'b10000;
		tiles[1] <= 5'b01000;
		tiles[2] <= 5'b00100;
		tiles[3] <= 5'b00010;
		count <= 0;
		incoming <= 5'b00001;
	end
	else if (count == 7'b1111000)
	begin
		tiles[0] <= incoming;
		count <= 0;
		incoming <= 1'b1 << (random%5);
		tiles[3] <= tiles[2];
		tiles[2] <= tiles[1];
		tiles[1] <= tiles[0];
		
	end
	else begin
		count <= count + 1;
	end

end

//handle drawing (may either be combinational or sequential - or both).
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
//	else if (vramOutput[15] == 1'b1)
//	begin
//	
//		if (fontRomBit == 1'b1)  
//			begin
//				red <= paletteBKG[11:8];
//				green <= paletteBKG[7:4];
//				blue <= paletteBKG[3:0];
//			end
//			
//			else 
//			begin
//				red <= paletteFGD[11:8];
//				green <= paletteFGD[7:4];
//				blue <= paletteFGD[3:0];
//			end
//	end
//	
//	else
//	begin
//		if (fontRomBit == 1'b0)  
//			begin
//			red <= paletteBKG[11:8];
//			green <= paletteBKG[7:4];
//			blue <= paletteBKG[3:0];
//		end
//		
//		else 
//		begin
//			red <= paletteFGD[11:8];
//			green <= paletteFGD[7:4];
//			blue <= paletteFGD[3:0];
//		end
//	end
	


end






		

endmodule