`include "define.h"

module pipeline_id_tb ();
  reg clk;
  reg rst;

  reg [31:0] inst;
  wire [2:0] decode_res;
  wire [`ALU_OPCODE_WIDTH] alu_opcode;

  pipeline_id DUT(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .decoded_type(decode_res),
    .alu_opcode(alu_opcode)
    );

// clock
initial begin
  clk = 1'b0;
  rst = 1'b1;
  repeat(4) #10 clk = ~clk;
  rst = 1'b0;
  forever #10 clk = ~clk; // generate a clock
end

initial begin
  $display("test: id");
  @(negedge rst);
  inst = $random;
  inst[`POS_OPCODE] = `R_TYPE_OPCODE;
  inst[`POS_FUNCT3] = `ADD_FUNCT3;
  inst[`POS_FUNCT7] = `ADD_FUNCT7;
  @(posedge clk);
  #5;
  if (alu_opcode != `ALU_ADD)
    $display("%d != %d (ans)", alu_opcode, `ALU_ADD);
  $display("finish: id");
  $finish;
end

endmodule // pipeline_id_tb
