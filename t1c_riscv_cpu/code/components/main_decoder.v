
// main_decoder.v
/*module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    input        Zero, ALUR31,
	 input        carryout,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump, jalr,
    output [1:0] ImmSrc,
    output [1:0] ALUOp
);

    reg [10:0] controls;
    reg TakeBranch = 0;

    always @(*) begin
        TakeBranch = 0;
        casez (op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_jalr
            7'b0000011: controls = 11'b1_00_1_0_01_00_0_0; // lw (and other loads)
            7'b0100011: controls = 11'b0_01_1_1_00_00_0_0; // sw (S-type immediate)
            7'b0110011: controls = 11'b1_xx_0_0_00_10_0_0; // R–type
            7'b1100011: begin //Branch (B-type immediate)
                        controls = 11'b0_10_0_0_00_01_0_0;
                        case(funct3)
                            3'b000: TakeBranch = Zero;
                            3'b001: TakeBranch = !Zero;
                            3'b100: TakeBranch = ALUR31;
                            3'b101: TakeBranch = !ALUR31;
									 3'b110: TakeBranch = !carryout;
                            3'b111: TakeBranch = carryout;
                        endcase
                      end
            7'b0010011: begin // I–type ALU instructions
                if (funct3 == 3'b001 || funct3 == 3'b101) begin // slli, srli, srai
                    controls = 11'b1_11_1_0_00_10_0_0;
                end else begin // addi, slti, sltiu, xori, ori, andi
                    controls = 11'b1_00_1_0_00_10_0_0;
                end
            end
            7'b1101111: controls = 11'b1_10_0_0_10_00_1_0; // jal (J-type immediate)
            7'b1100111: controls = 11'b1_00_1_0_10_00_0_1; // jalr
            7'b0?10111: controls = 11'b1_xx_x_0_11_xx_0_0; // lui, auipc
            default:    controls = 11'bx_xx_x_x_xx_xx_x_x;
        endcase
    end
    assign Branch = TakeBranch;
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, jalr} = controls;

endmodule*/


// main_decoder.v - FINAL CORRECTED VERSION
module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    input        Zero, ALUR31,
    input        carryout, // Standardized Name
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump, jalr,
    output [1:0] ImmSrc,
    output [1:0] ALUOp
);

    reg [10:0] controls;
    reg TakeBranch = 0;

    always @(*) begin
        TakeBranch = 0;
        casez (op)
            7'b0000011: controls = 11'b1_00_1_0_01_00_0_0;
            7'b0100011: controls = 11'b0_01_1_1_00_00_0_0;
            7'b0110011: controls = 11'b1_xx_0_0_00_10_0_0;
            7'b1100011: begin // Branch Logic
                controls = 11'b0_10_0_0_00_01_0_0;
                case(funct3)
                    3'b000: TakeBranch = Zero;          // beq
                    3'b001: TakeBranch = !Zero;         // bne
                    3'b100: TakeBranch = ALUR31;        // blt
                    3'b101: TakeBranch = !ALUR31;       // bge
                    3'b110: TakeBranch = !carryout;     // bltu (branch if a < b)
                    3'b111: TakeBranch = carryout;      // bgeu (branch if a >= b)
                endcase
            end
            7'b0010011: controls = 11'b1_00_1_0_00_10_0_0;
            7'b1101111: controls = 11'b1_11_0_0_10_00_1_0;
            7'b1100111: controls = 11'b1_00_1_0_10_00_0_1;
            7'b0?10111: controls = 11'b1_xx_x_0_11_xx_0_0;
            default:    controls = 11'bx_xx_x_x_xx_xx_x_x;
        endcase
    end
    assign Branch = TakeBranch;
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, jalr} = controls;
endmodule