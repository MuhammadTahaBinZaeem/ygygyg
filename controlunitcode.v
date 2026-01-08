`timescale 1ns / 1ps

module controlunitcode(
input [4:0] opcode, // 5-bit instruction opcode tell CPU what to perform
input wire zero,
output reg reg_write, // write to register file
output reg mem_read, // read from data memory
output reg mem_write, // write to data memory
output reg pc_jump, // control for jump
output reg pc_branch,
output reg write_lo,
output reg write_hi,
output reg [4:0] alu_op // ALU operation selector
    );

reg branch;
always @(*)
begin
reg_write= 0;
mem_read = 0;
mem_write = 0;
pc_jump = 0;
branch=0;
pc_branch=0;
alu_op = 5'b00000;
write_lo=0;
write_hi=0;

//everything starts with OFF
// checking all opcodes one by one

if (opcode == 5'b00000) //add instruction
begin
reg_write = 1;
alu_op = 5'b00000;;
end

else if (opcode == 5'b00100) // and instruction
begin
reg_write = 1;
alu_op = 5'b00100;
end

else if (opcode == 5'b00011) //or instruction
begin
reg_write = 1;
alu_op = 5'b00011;
end

else if (opcode == 5'b00001) // sll instruction
begin
reg_write = 1;
alu_op = 5'b00001;
end

else if (opcode == 5'b00010) // slr instruction
begin
reg_write = 1;
alu_op = 5'b00010;
end

else if (opcode == 5'b00101) // addi instruction
begin
reg_write = 1;
alu_op = 5'b00101;
end

else if (opcode == 5'b00110) // li instruction
begin
reg_write = 1;
alu_op = 5'b00110;
end

else if (opcode == 5'b00111) // lw instruction
begin
reg_write = 1;
mem_read = 1;
alu_op = 5'b00000;
end

else if (opcode == 5'b01000) // sw instruction
begin
mem_write = 1;
alu_op = 5'b00000;
end

else if (opcode == 5'b01001) // jump instruction
begin
pc_jump = 1;
end

else if (opcode == 5'b01010) //beqz instruction
begin
branch=1;
pc_branch=branch & zero;
alu_op = 5'b01010;
end

else if (opcode == 5'b01011) // beq instruction
begin
branch = 1;
pc_branch=branch&zero;
alu_op = 5'b01011;
end

else if (opcode == 5'b01101) // mul instruction
begin
reg_write = 1;
alu_op = 5'b01101;
end

else if (opcode == 5'b01100) // mfhi instruction
begin
reg_write = 1;
alu_op=5'b01100;
write_hi=1;
end

else if (opcode == 5'b01110) //mflo instruction
begin
reg_write = 1;
alu_op=5'b01110;
write_lo=1;
end

else if (opcode == 5'b01111) // vadd instruction
begin
reg_write = 1;
alu_op = 5'b01111;
end

else if (opcode == 5'b10000) // vmul instruction
begin
reg_write = 1;
alu_op = 5'b10000;
end

else if (opcode == 5'b10010) // vli (vector load immediate) instruction
begin
reg_write = 1;
alu_op = 5'b10010;
end

else if (opcode == 5'b10001) // vaddi instruction
begin
reg_write = 1;
alu_op = 5'b10001;
end

else if (opcode == 5'b10011) // lw_lane (load word into SIMD lane) instruction
begin
reg_write = 1;
mem_read = 1;
alu_op = 5'b10011;
end

// else: do nothing
end

endmodule






