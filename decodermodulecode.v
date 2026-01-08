`timescale 1ns / 1ps

module decodermodulecode(
input [19:0] instruction,
output reg [2:0] rs1,       // first source register
output reg [2:0] rs2,       // second source register (for R-type only)
output reg [2:0] rd,        // destination register
output reg [63:0] operand_2, // second operand (shift, immediate, or 0 if R-type)
output reg [4:0] alu_op,    // ALU operation
output reg [1:0] lane,      // lane select (for modified I)
output reg [7:0]jump_address,
output reg signed [7:0]branch_offset
    );
// Extract fields from instruction
wire [4:0]opcode=instruction[19:15];
wire [2:0]rd_field=instruction[5:3];
wire [2:0]rs1_field=instruction[8:6];
wire [2:0]rs2_field=instruction[11:9];
wire [5:0]shamt=instruction[5:0];
wire [8:0]imm=instruction[8:0];
wire [1:0]lane_field=instruction[1:0];

 always @(*) 
  begin
    // Default values
    alu_op=opcode;
    rd=rd_field;
    rs1=rs1_field;
    rs2=3'b000;
    operand_2=64'b0;
    lane=lane_field;
	 jump_address=8'b0;
	 branch_offset=8'b0;
	 
    if (opcode==5'b01010||opcode==5'b01011)
			  begin 
			   branch_offset=instruction[7:0];
			  end
// R-type instructions: use second register
    if (opcode==5'b00000||opcode==5'b01111||opcode==5'b01101||opcode==5'b10000||opcode==5'b00011||opcode==5'b00100) 
	   begin
        rs2=rs2_field;     // send rs2 to register file
        operand_2=64'b0;    // ALU will pick value from reg file using rs2
      end
// Shift instructions: use shamt as second operand
    else if (opcode==5'b00001||opcode == 5'b00010)
   	 begin
        rs2=3'b000;        // not used
        operand_2={{58{1'b0}},shamt}; // extend shift amount to 64bit
       end
// I-type instructions: use immediate as second operand
    else if (opcode==5'b00101||opcode==5'b00110||opcode==5'b10010||opcode==5'b10001)
	   begin
        rs2=3'b000;        // not used
        operand_2={{55{imm[8]}},imm}; // signextend 9bit immediate to 64bit
      end
// Modified I / vector lane load: constant+lane
    else if (opcode==5'b10011) 
	   begin
        rs2=3'b000;        // not used
        operand_2={{55{1'b0}},imm};  // constant part
        lane=lane_field;   // lane select
      end
//jump address 
    else if (opcode==5'b01001)
	   begin 
		  jump_address=instruction[9:2];
		end
//mflo and mfhi
    else if (opcode==5'b01100||opcode==5'b01110)
	   begin 
		  rs2=3'b000; 
		  operand_2=64'b0;
		end
//lw and sw
    else if (opcode==5'b00111||opcode==5'b01000)
	   begin
		  rs2=3'b000; 
		  operand_2={{55{imm[8]}},imm};
		end

end

endmodule



