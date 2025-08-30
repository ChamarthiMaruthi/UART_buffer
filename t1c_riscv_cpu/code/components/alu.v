// alu.v
/*module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,
    input       [3:0] alu_ctrl,
    output reg  [WIDTH-1:0] alu_out,
    output      zero,
	 output reg  carryout);

reg [WIDTH:0] sub_result;
reg [WIDTH:0] add_result;
always @(*) begin
    
    sub_result = {1'b0, a} - {1'b0, b};
    add_result = {1'b0, a} + {1'b0, b};
	 carryout = 1'b0;
    case (alu_ctrl)
        4'b0000: begin // ADD or ADDI
                alu_out = add_result[WIDTH-1:0];
                carryout = add_result[WIDTH]; // Pass through the carry from addition
            end
         4'b1000: begin // SUB or any Branch comparison
                alu_out = sub_result[WIDTH-1:0];
                carryout = !sub_result[WIDTH];
            end
        4'b0001: alu_out = a << b[4:0];                  // SLL, SLLI
        4'b0010: alu_out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT, SLTI
        4'b0011: alu_out = (a < b) ? 32'd1 : 32'd0;       // SLTU, SLTIU
        4'b0100: alu_out = a ^ b;                        // XOR, XORI
        4'b0101: alu_out = a >> b[4:0];                  // SRL, SRLI (logical)
        4'b1101: alu_out = $signed(a) >>> b[4:0];        // SRA, SRAI (arithmetic)
        4'b0110: alu_out = a | b;                        // OR, ORI
        4'b0111: alu_out = a & b;                        // AND, ANDI
		  4'b1010: alu_out = (a < b) ? 32'd1 : 32'd0;       // BLTU (unsigned)
		  4'b1011: alu_out = (a >= b) ? 32'd1 : 32'd0;      // BGEU (unsigned)
        default: alu_out = 32'hffffffff;                 // unknown op
    endcase
end

assign zero = (alu_out == 32'b0);

endmodule*/


// alu.v - FINAL CORRECTED VERSION
module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,
    input       [3:0]       alu_ctrl,
    output reg  [WIDTH-1:0] alu_out,
    output      zero,
    output reg  carryout // Standardized Name
);

    wire [4:0] shamt = b[4:0];
        reg [WIDTH:0] sub_result;
        reg [WIDTH:0] add_result;
    always @(*) begin

        
        sub_result = {1'b0, a} - {1'b0, b};
        add_result = {1'b0, a} + {1'b0, b};

        carryout = 1'b0; // Default

        case (alu_ctrl)
            4'b0000: begin // ADD / ADDI / LW / SW
                alu_out = add_result[WIDTH-1:0];
                carryout = add_result[WIDTH];
            end
            4'b1000: begin // SUB / ALL BRANCHES (beq, blt, bgeu, etc.)
                alu_out = sub_result[WIDTH-1:0];
                // CarryOut is 1 if a >= b (no borrow). 0 if a < b (borrow).
                carryout = !sub_result[WIDTH];
            end
            
            // All other ALU operations
            4'b0001: alu_out = a << shamt;
            4'b0010: alu_out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b0011: alu_out = (a < b) ? 32'd1 : 32'd0;
            4'b0100: alu_out = a ^ b;
            4'b0101: alu_out = a >> shamt;
            4'b1101: alu_out = $signed(a) >>> shamt;
            4'b0110: alu_out = a | b;
            4'b0111: alu_out = a & b;
            
            default: alu_out = 32'hffffffff;
        endcase
    end
    assign zero = (alu_out == 32'b0);
endmodule
