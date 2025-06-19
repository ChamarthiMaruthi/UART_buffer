
/* controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, ALUR31,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump, jalr,
    output [1:0] ImmSrc,
    output [2:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;

main_decoder    md (op, funct3, Zero, ALUR32, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch
assign PCSrc = Branch | Jump;

endmodule*/

// controller.v - CORRECTED
module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, ALUR31,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump, jalr,
    output [1:0] ImmSrc,
    // THE FIX: ALUControl is now 4 bits
    output [3:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;

// Note: Your main_decoder has an ALUR32 input, but your controller has ALUR31.
// I am assuming it should be ALUR31. If not, correct this wire name.
main_decoder    md (op, funct3, Zero, ALUR31, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

assign PCSrc = Branch | Jump;

endmodule