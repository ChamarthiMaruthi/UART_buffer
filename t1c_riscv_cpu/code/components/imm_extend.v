
// imm_extend.v - logic for sign extension



module imm_extend (
    input  [31:7]     instr,
    input  [1:0]      immsrc,
    output reg [31:0] immext
);



always @(*) begin
    case(immsrc)
        //2'b00: immext = {{20{instr[31]}}, instr[31:20]};
		  2'b00: begin
            if (instr[31:25] == 7'b0000000 || instr[31:25] == 7'b0100000) begin
                immext = {{27{1'b0}}, instr[24:20]};
            end else begin
                immext = {{20{instr[31]}}, instr[31:20]};
            end
        end
        2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        2'b11: immext = {27'b0, instr[24:20]};
        default: immext = 32'bx;
    endcase
end

endmodule
