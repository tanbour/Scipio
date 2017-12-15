/////////////////////////
//////////DEBUG//////////
`define R_TYPE 3'b000
`define I_TYPE 3'b001
/////////////////////////

`define R_TYPE_OPCODE 7'b0110011
`define I_TYPE_OPCODE 7'b0010011

// R
`define ADD_FUNCT73  10'b0000000000
`define SUB_FUNCT73  10'b0100000000
`define SLL_FUNCT73  10'b0000000001
`define SLT_FUNCT73  10'b0000000010
`define SLTU_FUNCT73 10'b0000000011
`define XOR_FUNCT73  10'b0000000100
`define SRL_FUNCT73  10'b0000000101
`define SRA_FUNCT73  10'b0100000101
`define OR_FUNCT73   10'b0000000110
`define AND_FUNCT73  10'b0000000111

// I
`define ADDI_FUNCT3 3'b000

// decoding
`define POS_OPCODE 6:0
`define POS_RD     11:7
`define POS_FUNCT3 14:12
`define POS_RS1    19:15
`define POS_RS2    24:20
`define POS_FUNCT7 31:25
`define POS_IMM    31:20
`define POS_IMM_H  31:25
`define POS_IMM_L  11:7
`define POS_IMM_EX 31:12
// todo: S/B/U/J type