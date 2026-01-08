`timescale 1ns / 1ps

module lohiregistercode(
input wire clock,
input wire reset,
input wire write_lo,
input wire write_hi,
input wire [15:0] value_lo,
input wire [15:0] value_hi,
input wire negative,
input wire overflow,
input wire carry, 
input wire zero,
output wire [15:0] data_lo,
output wire [15:0] data_hi,
output wire [15:0] data_status
    );

//making registers
reg [15:0] special_regs [2:0];

//assigning outputs 
assign data_lo = special_regs[0];
assign data_hi = special_regs[1];
assign data_status = special_regs[2];

//logic
always @(posedge clock or posedge reset)
begin
  if (reset==1)
   begin
    special_regs[0]<=16'b0;
	 special_regs[1]<=16'b0;
	 special_regs[2]<=16'b0;
   end
end 

always @(posedge clock or posedge reset)
begin 
  if (reset==1)
    begin
      special_regs[0]<=16'b0;
      special_regs[1]<=16'b0;
    end
  else
    begin
      if (write_lo==1)
        special_regs[0]<=value_lo;
      if (write_hi==1)
        special_regs[1]<=value_hi;
    end
end

always @(posedge clock or posedge reset)
begin
  if (reset==1)
    special_regs[2]<=16'b0;
  else if (overflow==1)
    special_regs[2]<=16'b00001;
  else if (carry==1)
    special_regs[2]<=16'b00010;
  else if (negative==1)
    special_regs[2]<=16'b00100;
  else if (zero==1)
    special_regs[2]<=16'b01000;
  else
    special_regs[2]<=16'b0;
end
	 
	 

endmodule
