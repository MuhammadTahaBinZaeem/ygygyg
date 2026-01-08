`timescale 1ns / 1ps

module statusregistermodule(
input wire clock,
input wire reset, 
input wire overflow,
input wire carry,
input wire negative,
input wire zero,
output reg [3:0] status_value
    );
	 
always @(posedge clock or posedge reset)
begin 
  if (reset==1)
    begin 
	   status_value<=4'b0;
	 end
  else 
    begin 
	   status_value[0]<=overflow;
		status_value[1]<=carry;
		status_value[2]<=negative;
		status_value[3]<=zero;
	 end
end


endmodule
