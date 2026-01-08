`timescale 1ns / 1ps
module instructionmemorymodulecode(
input wire [7:0]  pc,          // program counter
output wire [19:0] instruction  // 20-bit instruction
    );

reg [19:0] instr_memory [0:19];

initial
  begin
     instr_memory[0]=20'b00000000001010000000; // add R1,R2
     instr_memory[1]=20'b01111000001010000000; // vadd R1,R2
     instr_memory[2]=20'b00001000001010000000; // sll
     instr_memory[3]=20'b00010000001010000001; // slr
     instr_memory[4]=20'b01101000001010000000; // mul
     instr_memory[5]=20'b10000000001010000000; // vmul
     instr_memory[6]=20'b01110000001010000000; // mflo
     instr_memory[7]=20'b01100000001010000000; // mfhi
     instr_memory[8]=20'b00011000001010000000; // or 
     instr_memory[9]=20'b00100000001010000000; // and

     instr_memory[10]=20'b00101000001000000001; // addi
     instr_memory[11]=20'b10001000001000000001; // vaddi
     instr_memory[12]=20'b00110000001000000001; // li
     instr_memory[13]=20'b10010000001000000001; // vli
     instr_memory[14]=20'b00111000001000000001; // lw
     instr_memory[15]=20'b01000000001000000001; // sw
	  instr_memory[16]=20'b01010000001000000010; //beqz
	  instr_memory[17]=20'b01011000001000000010; //beq
	  instr_memory[18]=20'b10011000001000000001; //modified I
	  
	  instr_memory[19]=20'b01001000000000000000; //jump
   end
    assign instruction = instr_memory[pc[4:0]];
endmodule

