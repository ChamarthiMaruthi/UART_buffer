
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [3:0]   ALUControl,
    input			jalr,
    output        Zero, ALUR31,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
	 output        carryout
);

    wire [31:0] PCNext, PCjalr, PCPlus4, PCTarget, AuiPC, lauiPC;
    wire [31:0] ImmExt, SrcA, WriteData, ALUResult;
    reg  [31:0] LoadDataProcessed;
    wire [31:0] SrcB_from_regfile, SrcB_from_imm, SrcB;
	 wire        carryout_wire;
    wire        is_i_type_shift = (Instr[6:0] == 7'b0010011) &&
                                  (Instr[14:12] == 3'b001 || Instr[14:12] == 3'b101);
    wire [31:0] shamt_immediate = {{27{1'b0}}, Instr[24:20]};
    mux2 #(32)  shamt_mux(ImmExt, shamt_immediate, is_i_type_shift, SrcB_from_imm);
    mux2 #(32)  srcbmux(WriteData, SrcB_from_imm, ALUSrc, SrcB);
    mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
    mux2 #(32)     jalrmux(PCNext, ALUResult, jalr, PCjalr);
    reset_ff #(32) pcreg(clk, reset, PCjalr, PC);
    adder          pcadd4(PC, 32'd4, PCPlus4);
    adder          pcaddbranch(PC, ImmExt, PCTarget);
    reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
    imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

    // ALU now receives the corrected SrcB value
    alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero, carryout_wire);

    // These parts of the datapath are correct and remain unchanged
    adder #(32)    aupicadder({Instr[31:12], 12'b0}, PC, AuiPC);
    mux2 #(32)     lauipcmux(AuiPC,{Instr[31:12], 12'b0}, Instr[5], lauiPC);
    mux4 #(32)     resultmux(ALUResult, LoadDataProcessed, PCPlus4, lauiPC, ResultSrc, Result);
    assign ALUR31 = ALUResult[31];
    assign Mem_WrData = WriteData;
    assign Mem_WrAddr = ALUResult;
	 assign carryout = carryout_wire;

    // Load processing logic is correct and remains unchanged
    always @(*) begin
        case (Instr[14:12])
            3'b000: LoadDataProcessed = {{24{ReadData[7]}}, ReadData[7:0]};
            3'b001: LoadDataProcessed = {{16{ReadData[15]}}, ReadData[15:0]};
            3'b010: LoadDataProcessed = ReadData;
            3'b100: LoadDataProcessed = {{24{1'b0}}, ReadData[7:0]};
            3'b101: LoadDataProcessed = {{16{1'b0}}, ReadData[15:0]};
            default: LoadDataProcessed = ReadData;
        endcase
    end

endmodule