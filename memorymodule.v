`timescale 1ns / 1ps

module memorymodule(
input wire reset,
input wire clock,
input wire mem_read,
input wire mem_write,
input [7:0] addr,
input [15:0] sw_value,
output reg [15:0] lw_value
    );

reg [15:0] memory [0:9];

always @(posedge clock or posedge reset)
begin 
  if (reset==1)
   begin
    memory[0]<=16'b0;
	 memory[1]<=16'b0;
	 memory[2]<=16'b0;
	 memory[3]<=16'b0;
	 memory[4]<=16'b0;
	 memory[5]<=16'b0;
	 memory[6]<=16'b0;
	 memory[7]<=16'b0;
	 memory[8]<=16'b0;
	 memory[9]<=16'b0;
	end
  else if (mem_write==1 && addr<10)
    memory[addr]<=sw_value;
  else if (mem_read==1 && addr<10)
    lw_value<=memory[addr];
end 

endmodule
