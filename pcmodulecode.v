`timescale 1ns / 1ps

module pcmodulecode(
input wire clock,
input wire reset,
input wire pc_write,
input wire[7:0] pc_next,
output reg [7:0] pc
  );

always @(posedge clock or posedge reset) 
begin
  if (reset)
     pc <= 8'h00;

  else if (pc_write)
     pc <= pc_next;

end

endmodule
