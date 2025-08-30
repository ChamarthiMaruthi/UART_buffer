
// riscv_cpu.v
module riscv_cpu (
    input         clk, reset,
    output [31:0] PC,
    input  [31:0] Instr,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire        ALUSrc, RegWrite, Jump, jalr, Zero, ALUR31, PCSrc;
wire [1:0]  ResultSrc, ImmSrc;
// THE FIX: ALUControl wire is now 4 bits
wire [3:0]  ALUControl;
wire carryout;

/*controller  c   (Instr[6:0], Instr[14:12], Instr[30], Zero, ALUR31, carryout,
                ResultSrc, MemWrite, PCSrc, ALUSrc, RegWrite, Jump, jalr,
                ImmSrc, ALUControl);

datapath    dp  (clk, reset, ResultSrc, PCSrc,
                ALUSrc, RegWrite, ImmSrc, ALUControl, jalr,
                Zero, ALUR31, Carryout, PC, Instr, Mem_WrAddr, Mem_WrData, ReadData, Result);*/
					 
controller  c (
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .Zero(Zero),
        .ALUR31(ALUR31),
        .carryout(carryout), // Correctly connected
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .jalr(jalr),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    // --- Datapath Instantiation (using named connections to fix the bug) ---
    datapath    dp  (
        // Inputs
        .clk(clk),
        .reset(reset),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        .jalr(jalr),
        .Instr(Instr),
        .ReadData(ReadData),

        // Outputs
        .Zero(Zero),
        .ALUR31(ALUR31),
        .carryout(carryout), // Correctly connected
        .PC(PC),
        .Mem_WrAddr(Mem_WrAddr),
        .Mem_WrData(Mem_WrData),
        .Result(Result)
    );

endmodule

