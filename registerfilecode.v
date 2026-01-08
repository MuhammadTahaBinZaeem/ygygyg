`timescale 1ns / 1ps
module registerfilecode(
input wire clock,          //signal for clock
input wire reset,          //signal for reset 
input wire [2:0] reg_addr_1,    //address of first register that is to be read
input wire [2:0] reg_addr_2,    //address of second register that is to be read
input wire write_reg,           //signal that tells if you need to write in a register
input wire [2:0] write_reg_addr,   //address of register in which you will write
input wire [63:0] write_reg_value,  //value that you will write in register
output wire [63:0] value_1,        //value from first register that you read
output wire [63:0] value_2       //value from second register that you read
    );
 
//creating registers
reg [63:0] registers [7:0]; 

//assigning values to the two registers that must be read 
assign value_1= registers[reg_addr_1];
assign value_2= registers[reg_addr_2];

//reset logic 
always @(posedge clock or posedge reset)
begin 
  if (reset==1)
     begin 
	    registers[0]<= 64'b0;
		 registers[1]<= 64'b0;
		 registers[2]<= 64'b0;
		 registers[3]<= 64'b0;
		 registers[4]<= 64'b0;
		 registers[5]<= 64'b0;
		 registers[6]<= 64'b0;
		 registers[7]<= 64'b0;
	  end
//logic if we want to write in a register 
  else if (write_reg==1) 
	   registers[write_reg_addr]<=write_reg_value;
end
endmodule

