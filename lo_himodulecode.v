`timescale 1ns / 1ps

module lo_himodulecode(
input wire clock,
input wire reset,
input wire write_lo,
input wire write_hi,
input wire [15:0] value_lo,
input wire [15:0] value_hi,
output wire [15:0] data_lo,
output wire [15:0] data_hi
    );

//making registers
reg [15:0] lohi_regs [1:0];


//logic
always @(posedge clock or posedge reset)
begin
  if (reset==1)
   begin
    lohi_regs[0]<=16'b0;
	 lohi_regs[1]<=16'b0;
   end

  if (write_lo==1)
    begin
	   lohi_regs[0]<=value_lo;
	 end

  if (write_hi==1)
    begin
	   lohi_regs[1]<=value_hi;
	 end
end



//assigning outputs 
assign data_lo=lohi_regs[0];
assign data_hi=lohi_regs[1];
endmodule

 



