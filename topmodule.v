`timescale 1ns / 1ps

module topmodule(
input wire clock,
input wire reset
    );
wire [7:0] pc,pc_next;   //pc modules
wire pc_write;
wire[19:0]instruction;   //instruction memory
wire[2:0] rs1,rs2,rd;    //decoder module 
wire[63:0] operand_2;
wire[4:0] alu_op;
wire [4:0] decoder_alu_op;
wire[1:0] lane;
wire [7:0] jump_address;
wire signed [7:0] branch_offset;
wire reg_write,mem_read,mem_write,pc_jump,pc_branch; //control unit 
wire write_lo,write_hi;
wire [63:0] value_1,value_2;        //registerfile
wire [63:0] result;             //alu
wire[15:0] lo,hi;
wire zero,negative,carry,overflow;
wire [15:0] data_lo,data_hi;      //lo hi module
wire [15:0] lw_value;
wire [3:0] status_value;            //status module 

pcmodulecode PC (
.clock(clock),
.reset(reset),
.pc_write(pc_write),
.pc_next(pc_next),
.pc(pc)
  );

assign pc_write = 1'b1;
  
pcnextmodulecode PCNEXT (
.pc(pc),
.jump(pc_jump),
.branch(pc_branch),
.jump_address(jump_address),
.branch_offset(branch_offset),
.pc_next(pc_next)
  );
  
instructionmemorymodulecode IM (
.pc(pc),
.instruction(instruction)

 );
  
decodermodulecode DC (
.instruction(instruction),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.operand_2(operand_2),
.alu_op(decoder_alu_op),
.lane(lane),
.jump_address(jump_address),
.branch_offset(branch_offset)
  );
  
controlunitcode CU (
.opcode(instruction[19:15]),
.zero(zero),
.reg_write(reg_write),
.mem_read(mem_read),
.mem_write(mem_write),
.pc_jump(pc_jump),
.pc_branch(pc_branch),
.write_lo(write_lo),
.write_hi(write_hi),
.alu_op(alu_op)
  );
  
registerfilecode RF (
.clock(clock),
.reset(reset),
.reg_addr_1(rs1),
.reg_addr_2(rs2),
.write_reg(reg_write),
.write_reg_addr(rd),
.write_reg_value(result),
.value_1(value_1),
.value_2(value_2)
  );
  
alumodulecode ALU (
.operand_1(value_1),
.operand_2(operand_2),
.alu_op(alu_op),
.lane_id(lane),
.mem_data(lw_value),
.result(result),
.lo(lo),
.hi(hi),
.zero(zero),
.negative(negative),
.carry(carry),
.overflow(overflow)
  );
  
memorymodule DM (
.reset(reset),
.clock(clock),
.mem_read(mem_read),
.mem_write(mem_write),
.addr(result[7:0]),
.lw_value(lw_value),
.sw_value(value_2[15:0])
  );
  
lo_himodulecode LOHI (
.clock(clock),
.reset(reset),
.write_lo(write_lo),
.write_hi(write_hi),
.value_lo(lo),
.value_hi(hi),
.data_lo(data_lo),
.data_hi(data_hi)
  );
  
statusregistermodule SR (
.clock(clock),
.reset(reset),
.overflow(overflow),
.carry(carry),
.negative(negative),
.zero(zero),
.status_value(status_value)
  );



endmodule
