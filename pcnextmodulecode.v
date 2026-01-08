`timescale 1ns / 1ps

module pcnextmodulecode(
input [7:0] pc,         // current pc value
input jump,       // jump control signal
input [7:0] jump_address,  // target address for jump
input wire branch,
input wire signed [7:0] branch_offset,
output reg [7:0] pc_next // next pc value
    );

always @(*) 
begin
    if (pc==8'd255)
	     pc_next=8'd0;
    else if (jump)
        pc_next=jump_address[7:0];  // jump takes priority
	 else if (branch)
	     pc_next=pc+branch_offset[7:0];
    else 
        pc_next=pc+8'd1;  // normal pc increment
end

endmodule 
