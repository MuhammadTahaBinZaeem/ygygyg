`timescale 1ns / 1ps

module alumodulecode(
input wire [63:0] operand_1,
input wire [63:0] operand_2,
input wire [4:0] alu_op,
input wire [1:0] lane_id,
input wire [15:0] mem_data,
output reg [63:0] result,
output reg [15:0] lo,
output reg [15:0] hi,
output reg zero,
output reg negative,
output reg carry, 
output reg overflow
  );

reg [31:0] mul;

always @(*)
  begin
    result=64'b0;
	 lo=16'b0;
	 hi=16'b0;
	 zero=0;
	 negative=0;
	 carry=0;
	 overflow=0;

    if (alu_op==5'b00000)               //add
	   begin
      	{carry,result[15:0]}=operand_1[15:0]+operand_2[15:0];
			result[63:16]=48'b0;
			overflow=(~operand_1[15]& ~operand_2[15]&result[15])|
               (operand_1[15]&operand_2[15]& ~result[15]);
			  if (result==64'b0)
			    zero=1;
			  if (result[63]==1'b1)
			    negative=1;
		end
	 else if (alu_op==5'b01111)          //vadd
	    begin
	      result[15:0]=operand_1[15:0] + operand_2[15:0];
			result[31:16]=operand_1[31:16] + operand_2[31:16];
			result[47:32]=operand_1[47:32] + operand_2[47:32];
			result[63:48]=operand_1[63:48] + operand_2[63:48];
			carry =(result[15:0]<operand_1[15:0])|
         (result[31:16]<operand_1[31:16]) |
         (result[47:32]<operand_1[47:32]) |
         (result[63:48]<operand_1[63:48]);
			overflow=((~operand_1[15]& ~operand_2[15]&result[15])|
            ( operand_1[15]&operand_2[15]& ~result[15]))|
           ((~operand_1[31]&~operand_2[31]&result[31])|
            ( operand_1[31]& operand_2[31]&~result[31]))|
           ((~operand_1[47]&~operand_2[47]&result[47])|
            ( operand_1[47]& operand_2[47]&~result[47]))|
           ((~operand_1[63]&~operand_2[63]&result[63])|
            ( operand_1[63]& operand_2[63]&~result[63]));
			  if (result==64'b0)
			    zero=1;
			  if (result[63]==1'b1)
			    negative=1;
		 end
	 else if (alu_op==5'b00001)         //sll
	     begin
	      result=operand_1<<operand_2[5:0];
			  if (result==64'b0)
			    zero=1;
			  if (result[63]==1'b1)
			    negative=1;
		  end
	 else if (alu_op==5'b00010)        //slr
	     begin
	      result=operand_1>>operand_2[5:0];
			   if (result==64'b0)
			    zero=1;
		  end
	 else if (alu_op==5'b01101)        //mul
	   begin
	      mul=operand_1[15:0] * operand_2[15:0];
			lo=mul[15:0];
			hi=mul[31:16];
			  if (lo==16'b0 && hi==16'b0)
			    zero=1;
			  if (hi[15]==1'b1)
			    negative=1;
	   end
	 else if (alu_op==5'b10000)       //vmul
	   begin
		 result[15:0]=operand_1[15:0] * operand_2[15:0];
		 result[31:16]=operand_1[31:16] * operand_2[31:16];
		 result[47:32]=operand_1[47:32] * operand_2[47:32];
		 result[63:48]=operand_1[63:48] * operand_2[63:48];
		 carry=((operand_1[15:0]*operand_2[15:0])>>16)|
		       ((operand_1[31:16]*operand_2[31:16])>>16)|
				 ((operand_1[47:32]*operand_2[47:32])>>16)|
				 ((operand_1[63:48]*operand_2[63:48])>>16);
		    if (result==64'b0)
			    zero=1; 
			 if (result[63]==1'b1)
			    negative=1;
		end
	 else if (alu_op==5'b01110)      //mflo
	   begin
		  result={{48{lo[15]}},lo};
		    if (result==64'b0)
			    zero=1;
			 if (result[63]==1'b1)
			    negative=1;
		end 
	 else if (alu_op==5'b01100)     //mfhi
	   begin    
		  result={{48{hi[15]}},hi};
		    if (result==64'b0)
			    zero=1;
			 if (result[63]==1'b1)
			    negative=1;
		end
	 else if (alu_op==5'b00011)     //or
	   begin 
		  result= operand_1|operand_2;
		    if (result==64'b0)
			    zero=1;
		end
    else if (alu_op==5'b00100)    //and
	   begin 
		  result=operand_1&operand_2;
		     if (result==64'b0)
			    zero=1;
		end 
	 else if (alu_op==5'b00101)     //addi
	   begin 
		  {carry,result[15:0]}=operand_1[15:0] + operand_2[15:0];
		  result[63:16]=48'b0;
		  overflow=(~operand_1[15]& ~operand_2[15]&result[15])|
               (operand_1[15]&operand_2[15]& ~result[15]);
		    if (result==64'b0)
			    zero=1;
			 if (result[63]==1'b1)
			    negative=1;
		end 
	 else if (alu_op==5'b10001)     //vaddi
	   begin 
		  result[15:0]=operand_1[15:0] + operand_2[15:0];
		  result[31:16]=operand_1[31:16] + operand_2[31:16];
		  result[47:32]=operand_1[47:32] + operand_2[47:32];
		  result[63:48]=operand_1[63:48] + operand_2[63:48];
		  carry = (result[15:0]<operand_1[15:0])|
        (result[31:16]<operand_1[31:16])|
        (result[47:32]<operand_1[47:32])|
        (result[63:48]<operand_1[63:48]);
		  overflow=((~operand_1[15]& ~operand_2[15]&result[15])|
            ( operand_1[15]&operand_2[15]& ~result[15]))|
           ((~operand_1[31]&~operand_2[31]&result[31])|
            ( operand_1[31]& operand_2[31]&~result[31]))|
           ((~operand_1[47]&~operand_2[47]&result[47])|
            ( operand_1[47]& operand_2[47]&~result[47]))|
           ((~operand_1[63]&~operand_2[63]&result[63])|
            ( operand_1[63]& operand_2[63]&~result[63]));
		     if (result==64'b0)
			    zero=1;
			  if (result[63]==1'b1)
			    negative=1;
		end
	 else if (alu_op==5'b00111)   //lw
	   begin 
		  result=operand_1+operand_2;
		    if (result==64'b0)
			    zero=1;
		end 
	 else if (alu_op==5'b01000)    //sw
	   begin 
		  result=operand_1+operand_2;
		end
	 else if (alu_op==5'b10011)    //lw(laneid)
	    begin
		   result=operand_1;
		   if (lane_id==2'b00)
           begin
              result[15:0] = mem_data;
           end
         else if (lane_id==2'b01)
            begin
              result[31:16] = mem_data;
            end
         else if (lane_id==2'b10)
            begin
              result[47:32] = mem_data;
            end
         else if (lane_id==2'b11)
            begin
               result[63:48]=mem_data;
            end
		 end
     else if (alu_op==5'b01010)   //beqz
         begin 
           if (operand_1==64'b0)
             zero=1'b1;
           else 
             zero=1'b0;
         end 
     else if (alu_op==5'b01011)     //beq
          begin
            if (operand_1==operand_2)
              zero=1'b1;
            else 
              zero=1'b0;
          end 
			 
	  else if(alu_op== 5'b00110)  //li
	       begin 
			   result=operand_2;
			 end
	  else if(alu_op == 5'b10010)  //vli
	       begin
			   result[15:0]=operand_2[15:0];
				result[31:16]=operand_2[15:0];
				result[47:32]=operand_2[15:0];
				result[63:48]=operand_2[15:0];
				 if (result==64'b0)
				   zero=1;
				 if (result[63]==1'b1)
				   negative = 1;
			 end
end
endmodule
