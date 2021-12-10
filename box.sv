module box(input logic ObjectOn, input logic [9:0] DrawX, DrawY, output [3:0] Red, Green, Blue);
 
    logic [7:0] ObjectR, ObjectG, ObjectB;
	 
	 
    //logic  ObjectXSize = 10'd10;
    //parameter ObjectYSize = 10'd10;
	 
	 
	 
    always_comb begin
         if(ObjectOn == 1'b1)
         begin
             Red = ObjectR[7:4];
             Green = ObjectG[7:4];
             Blue = ObjectB[7:4];
         end
			else begin
				Red = 0;
				Green = 0;
				Blue = 0;
			end
	end
			
			
     present ost(
                           .SpriteX(200 - (DrawX + 100)), .SpriteY(200 - (DrawY + 100)),
                           .SpriteR(ObjectR), .SpriteG(ObjectG), .SpriteB(ObjectB)
              );

endmodule