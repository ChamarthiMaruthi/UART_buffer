/* alu.v - ALU module
module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [2:0] alu_ctrl,         // ALU control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero                    // zero flag
);

always @(*) begin
    case (alu_ctrl)
        3'b000:  alu_out = a + b;       // ADD, ADDI
        3'b001:  alu_out = a + ~b + 1;  // SUB
        3'b010:  alu_out = a & b;       // AND, ANDI
        3'b011:  alu_out = a | b;       // OR, ORI
        3'b100:  alu_out = a << b[4:0]; // SLLI - Shift left logical
        3'b101:  alu_out = (b < a) ? 1 : 0; // SLT, SLTI
        3'b110:  alu_out = ($signed(b) < $signed(a)) ? 1 : 0; // SLTU, SLTIU (signed comparison)
        3'b111:  alu_out = a ^ b;       // XOR, XORI
        3'b011:  alu_out = $unsigned(a) >> a[4:0]; // SRL, SRLI - Shift right logical
        3'b001:  alu_out = $signed(a) >>> b[4:0]; // SRA, SRAI - Shift right arithmetic
        default: alu_out = 0;
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule*/

/* alu.v - CORRECTED and REFACTORED
module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,           // operands
    input       [2:0] alu_ctrl,             // ALU control (now corresponds to funct3)
    input       alt_op,                     // NEW 1-bit control for SUB/SRA
    output reg  [WIDTH-1:0] alu_out,        // ALU output
    output      zero                        // zero flag
);

wire [4:0] shamt = b[4:0]; // Shift amount is the lower 5 bits of operand B

always @(*) begin
    case (alu_ctrl)
        // Operation based on funct3. Replaces old, conflicted logic.
        3'b000: // ADD or SUB
            alu_out = alt_op ? (a - b) : (a + b);

        3'b001: // SLL, SLLI (Shift Left Logical)
            alu_out = a << shamt;

        3'b010: // SLT, SLTI (Set Less Than, SIGNED)
            alu_out = $signed(a) < $signed(b) ? 32'd1 : 32'd0;

        3'b011: // SLTU, SLTIU (Set Less Than, UNSIGNED)
            alu_out = a < b ? 32'd1 : 32'd0;

        3'b100: // XOR, XORI
            alu_out = a ^ b;

        3'b101: // SRL/SRLI (Logical Right Shift) or SRA/SRAI (Arithmetic Right Shift)
            alu_out = alt_op ? ($signed(a) >>> shamt) : (a >> shamt);

        3'b110: // OR, ORI
            alu_out = a | b;

        3'b111: // AND, ANDI
            alu_out = a & b;

        default:
            alu_out = 32'hdeadbeef; // Should not happen in a working design
    endcase
end

assign zero = (alu_out == 32'b0); // Cleaner way to write this comparison

endmodule*/

// alu.v - CORRECTED
module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,
    // THE FIX: Input is now 4 bits wide
    input       [3:0] alu_ctrl,
    output reg  [WIDTH-1:0] alu_out,
    output      zero
);

wire [4:0] shamt = b[4:0];
wire       alt_op = alu_ctrl[3]; // The 4th bit is our selector
wire [2:0] op_code = alu_ctrl[2:0]; // The lower 3 bits are the main operation

always @(*) begin
    case (op_code) // Case on the lower 3 bits
        3'b000: // ADD or SUB
            alu_out = alt_op ? (a - b) : (a + b);
        3'b001: // SLL, SLLI
            alu_out = a << shamt;
        3'b010: // SLT, SLTI (SIGNED)
            alu_out = $signed(a) < $signed(b) ? 32'd1 : 32'd0;
        3'b011: // SLTU, SLTIU (UNSIGNED)
            alu_out = a < b ? 32'd1 : 32'd0;
        3'b100: // XOR, XORI
            alu_out = a ^ b;
        3'b101: // SRL/SRLI or SRA/SRAI
            alu_out = alt_op ? ($signed(a) >>> shamt) : (a >> shamt);
        3'b110: // OR, ORI
            alu_out = a | b;
        3'b111: // AND, ANDI
            alu_out = a & b;
        default:
            alu_out = 32'hdeadbeef;
    endcase
end

assign zero = (alu_out == 32'b0);

endmodule
