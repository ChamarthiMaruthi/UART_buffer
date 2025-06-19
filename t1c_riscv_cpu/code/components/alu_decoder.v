/*
// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [2:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000;             // addition
        2'b01: ALUControl = 3'b001;             // subtraction
        default:
            case (funct3) // R-type or I-type ALU
                3'b000: begin
                    // True for R-type subtract
                    if   (funct7b5 & opb5) ALUControl = 3'b001; //sub
                    else ALUControl = 3'b000; // add, addi
                end
                3'b010:  ALUControl = 3'b101; // slt, slti
                3'b110:  ALUControl = 3'b011; // or, ori
                3'b111:  ALUControl = 3'b010; // and, andi
                default: ALUControl = 3'bxxx; // ???
            endcase
    endcase
end

endmodule */

/* alu_decoder.v - logic for ALU decoder
module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [2:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000;             // addition
        2'b01: ALUControl = 3'b001;             // subtraction
        default:
            case (funct3) // R-type or I-type ALU
                3'b000: begin
                    if   (funct7b5 & opb5) ALUControl = 3'b001; // SUB
                    else ALUControl = 3'b000; // ADD, ADDI
                end
                3'b001:  ALUControl = 3'b100; // SLL, SLLI (shift left logical)
                3'b010:  ALUControl = 3'b101; // SLT, SLTI (signed comparison)
                3'b011:  ALUControl = 3'b110; // SLTU, SLTIU (unsigned comparison)
                3'b100:  ALUControl = 3'b111; // XOR, XORI
                3'b101:  ALUControl = funct7b5 ? 3'b011 : 3'b001; // SRL/SRLI (logical) or SRA/SRAI (arithmetic)
                3'b110:  ALUControl = 3'b011; // OR, ORI
                3'b111:  ALUControl = 3'b010; // AND, ANDI
                default: ALUControl = 3'bxxx; // ???
            endcase
    endcase
end


endmodule*/

/* alu_decoder.v - CORRECTED and REFACTORED
module alu_decoder (
    // Inputs from instruction and main control
    input            opb5,         // Opcode bit 5 (to know if it's an R-type)
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,

    // Outputs to the ALU
    output reg [2:0] ALUControl,   // The 3-bit control, will now be based on funct3
    output reg       alt_op        // NEW 1-bit signal for SUB/SRA
);

always @(*) begin
    case (ALUOp)
        2'b00: begin // For LW/SW, must be ADD
            ALUControl = 3'b000;  // ADD
            alt_op     = 1'b0;    // Don't subtract
        end
        2'b01: begin // For Branches, must be SUB
            ALUControl = 3'b000;  // ALU is in ADD/SUB mode
            alt_op     = 1'b1;    // Force a subtraction
        end
        default: begin // This is for R-Type and I-Type ALU instructions (ALUOp = 2'b10)
            ALUControl = funct3;  // The elegant solution: ALUControl is simply funct3!

            // Check for the special cases that use funct7b5
            if (funct3 == 3'b000 || funct3 == 3'b101) begin
                // Only R-type instructions (like SUB, SRA) use funct7.
                // opb5 is 1 for R-type.
                alt_op = funct7b5 & opb5; 
            end else begin
                alt_op = 1'b0; // Not a SUB/SRA operation
            end
        end
    endcase
end

endmodule*/

// alu_decoder.v - CORRECTED
module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    // THE FIX: Output is now 4 bits wide
    output reg [3:0] ALUControl
);

// The 4th bit (MSB) will be our SUB/SRA flag.
// The lower 3 bits will be based on funct3.
wire sub_or_sra_bit = funct7b5 & opb5; // Only for R-type instructions

always @(*) begin
    case (ALUOp)
        2'b00: // LW/SW -> must be ADD
            ALUControl = 4'b0000;  // {flag=0, op=ADD}

        2'b01: // Branches -> must be SUB for comparison
            ALUControl = 4'b1000;  // {flag=1, op=ADD/SUB} -> SUB

        default: // R-Type and I-Type ALU instructions (ALUOp = 2'b10)
            // For I-types, funct7b5 is not used, so the flag bit is 0.
            // For R-types, it is used for SUB and SRA.
            ALUControl = {sub_or_sra_bit, funct3};
    endcase
end

endmodule
