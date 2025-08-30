
// alu_decoder.v
module alu_decoder( 
	 input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)

            2'b00:
                ALUControl = 4'b0000;
            2'b01:
                ALUControl = 4'b1000;
            2'b10: begin
                ALUControl = {((funct3 == 3'b101) & funct7b5 | opb5 & funct7b5 & (funct3 == 3'b000)), funct3};
            end
            2'b11:
                ALUControl = 4'b0000;

            default:
                ALUControl = 4'b0000;

        endcase
    end

endmodule