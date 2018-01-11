`timescale 1ns/1ps

`include "common_def.h"

interface pif_ifid_inf;
  bit [`COMMON_WIDTH] inst;
  bit [`COMMON_WIDTH] pc_addr;

  modport pif (output inst, pc_addr);
  modport ifid (input inst, pc_addr);
endinterface

interface if_icache_inf;
  bit read_flag;
  bit [31:0] addr;
  bit [31:0] read_data;
  bit busy;
  bit done;

  modport pif (output read_flag, addr,
               input  read_data, busy, done);
endinterface

module pif (
  input clk,
  input rst,

  jump_stall_inf.pif jump_stall,
  full_stall_inf.pif full_stall,

  pif_ifid_inf.pif to_idif,

  if_icache_inf.pif    with_icache
  );

  reg reading;

  wire [`COMMON_WIDTH] pc_out_pc_addr;
  reg  [`COMMON_WIDTH] next_pc;

  // assign to_idif.pc_addr = pc_out_pc_addr;

  wire stall = jump_stall.stall || full_stall.stall;

  reg discard;
  always @ (posedge rst) begin
    reading = 0;
    discard = 0;
    // flag = 0;
    stalled_by_jump = 0;
  end

  reg [`COMMON_WIDTH] jump_addr;
  reg stalled_by_jump;
  always @ (negedge jump_stall.stall) begin
    discard = 1;
    if (jump_stall.jump_en)
      jump_addr = jump_stall.jump_addr;
    else
      jump_addr = pc_out_pc_addr;
  end

  always @ (posedge clk) begin
    stalled_by_jump = 0;
  end

  // next pc
  always @ ( * ) begin
    if (jump_stall.stall) begin
      stalled_by_jump = 1;
      next_pc <= 0;
    end else if (reading || full_stall.stall) begin

      next_pc <= stalled_by_jump ? jump_addr : pc_out_pc_addr;
    end else begin
      stalled_by_jump <= 0;
      next_pc <= pc_out_pc_addr + 4;
    end
  end

  /*
  always @ (posedge jump_stall.stall) begin
    reserved = 0;
    flag = 1;
  end
  reg [`COMMON_WIDTH] reserve_addr;
  reg reserved;
  reg flag;
  always @ ( * ) begin
    if (stall) begin
      next_pc = pc_out_pc_addr;
      if (jump_stall.stall) begin
        next_pc = 0;
        if (!reserved) begin
          reserved = 1;
          reserve_addr = pc_out_pc_addr;
        end
      end
    end else if (jump_stall.jump_en) begin
      next_pc = jump_stall.jump_addr;
      flag = 0;
    end else if (flag) begin
      // $display("branch not token");
      next_pc = reserve_addr;
      reserved = 0;
      flag = 0;
    end else if (reading) begin
    end else begin
      // $display("+4");
      next_pc = pc_out_pc_addr + 4;
    end
  end
  */



  always @ ( * ) begin
    to_idif.inst = 0;
    with_icache.read_flag = 0;
    if (rst || pc_out_pc_addr == -4) begin
      to_idif.inst = 0;
      with_icache.read_flag = 0;
    end else if (with_icache.done) begin
      // if (!discard) begin
        to_idif.inst = with_icache.read_data;
        to_idif.pc_addr = pc_out_pc_addr;
      // end else begin
      //   to_idif.inst = 0;
      //   discard = 0;
      // end
      reading = 0;
    end else if (!with_icache.busy) begin
      with_icache.read_flag = 1;
      with_icache.addr = pc_out_pc_addr;
      reading = 1;
    end else if (with_icache.busy) begin
      with_icache.read_flag = 0;
    end
  end

  pc_reg pc (
    .clk(clk),
    .rst(rst),

    .next_pc(next_pc),

    .pc_addr(pc_out_pc_addr)
    );


  // 2
  // wire [`COMMON_WIDTH] pc_out_pc_addr;
  // reg  [`COMMON_WIDTH] next_pc;
  //
  // wire stall = jump_stall.stall || full_stall.stall || with_icache.busy;

  // 1
  // assign next_pc = (jump_stall.jump_en) ? jump_stall.jump_addr : pc_out_pc_addr + 4;
  // reg jump;
  // reg [`COMMON_WIDTH] jump_addr;
  // always @ (posedge jump_stall.jump_en) begin
  //   jump = 1;
  //   jump_addr = jump_stall.jump_addr;
  // end
  //
  // pc_reg pc (
  //   .clk(clk),
  //   .rst(rst),
  //
  //   .stall(stall),
  //   .jump(jump_stall.jump_en),
  //
  //   .next_pc(next_pc),
  //
  //   .pc_addr(pc_out_pc_addr)
  //   );

  // 2
  // reg jump;
  // always @ ( * ) begin
  //   if (rst || flag) begin
  //     ;
  //   end else if (jump_stall.jump_en)
  //     next_pc = jump_stall.jump_addr;
  //     // jump = 1;
  //   else if (stall || !with_icache.done)
  //     next_pc = pc_out_pc_addr;
  //   else
  //     next_pc = pc_out_pc_addr + 4;
  // end
  //
  // pc_reg pc (
  //   .clk(clk),
  //   .rst(rst),
  //
  //   .next_pc(next_pc),
  //
  //   .pc_addr(pc_out_pc_addr)
  // );
  //
  // reg stall_flag;
  //
  // always @ (posedge rst) begin
  //   jump = 0;
  //   stall_flag = 0;
  // end
  //
  // always @ (negedge jump_stall.stall) begin
  //   stall_flag = 0;
  // end
  //
  // always @ ( * ) begin
  //   to_idif.inst = 0;
  //   with_icache.read_flag = 0;
  //   if (rst || pc_out_pc_addr == -4) begin
  //     to_idif.inst = 0;
  //     with_icache.read_flag = 0;
  //   end else if (with_icache.done) begin
  //     to_idif.inst = with_icache.read_data;
  //     to_idif.pc_addr = pc_out_pc_addr;
  //     if (to_idif.inst[`POS_OPCODE] == `JAL_OPCODE || to_idif.inst[`POS_OPCODE] == `JALR_OPCODE
  //       || to_idif.inst[`POS_OPCODE] == `BRANCH_OPCODE) begin
  //         stall_flag = 1;
  //     end
  //   end else if (!with_icache.busy) begin
  //     with_icache.read_flag = 1;
  //     with_icache.addr = pc_out_pc_addr;
  //   end else if (with_icache.busy) begin
  //     with_icache.read_flag = 0;
  //   end
  // end

endmodule : pif
