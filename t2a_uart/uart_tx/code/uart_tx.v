	// EcoMender Bot : Task 2A - UART Transmitter
	/*
	Instructions
	-------------------
	Students are not allowed to make any changes in the Module declaration.

	This file is used to generate UART Tx data packet to transmit the messages based on the input data.

	Recommended Quartus Version : 20.1
	The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

	Warning: The error due to compatibility will not be entertained.
	-------------------
	*/

	/*
	Module UART Transmitter

	Input:  clk_3125 - 3125 KHz clock
			  parity_type - even(0)/odd(1) parity type
			  tx_start - signal to start the communication.
			  data    - 8-bit data line to transmit

	Output: tx      - UART Transmission Line
			  tx_done - message transmitted flag
	*/

	// module declaration
	module uart_tx(
		 input clk_3125,
		 input parity_type,tx_start,
		 input [7:0] data,
		 output reg tx, tx_done
	);

	//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

	initial begin
		 tx = 1;
		 tx_done = 0;
	end

// --- Parameters and State Definitions ---
    localparam CLOCKS_PER_BIT = 14;
    localparam FINAL_CYCLE    = 13;
    
    localparam S_IDLE   = 4'b0000;
    localparam S_START  = 4'b0001;
    localparam S_DATA   = 4'b0010;
    localparam S_PARITY = 4'b0011;
    localparam S_STOP   = 4'b0100;
    localparam S_DONE   = 4'b0101;

    // --- Internal Registers ---
    reg [3:0]  state = S_IDLE;
    reg [3:0]  clk_counter = 0;
    // We send MSB first as per the documentation. Let the testbench do the reversing.
    reg [2:0]  bit_counter = 0;
    reg [7:0]  data_reg;
    reg        parity_bit_reg;
    
    //----------------------------------------------------------------------
    // SEQUENTIAL BLOCK: Handles state transitions and counters.
    // This part only changes on the clock edge.
    //----------------------------------------------------------------------
    always @(posedge clk_3125) begin
	 tx_done <= 0;
        case(state)
            S_IDLE: begin
                clk_counter <= 0;
                bit_counter <= 0;
                if (tx_start) begin
                    data_reg <= data;
                    parity_bit_reg <= (^data) ^ parity_type;
                    state <= S_START;
                end
            end
            
            S_START: begin
                if (clk_counter == FINAL_CYCLE) begin
                    clk_counter <= 0;
                    state <= S_DATA;
                    bit_counter <= 7; // Prepare to send MSB (data[7])
                end else begin
                    clk_counter <= clk_counter + 1;
                end
					 $display("Time: %0t | State: S_START | clk_counter = %0d, bit_counter = %0d, tx = %0b", $time, clk_counter, bit_counter, tx);
            end

            S_DATA: begin
                if (clk_counter == FINAL_CYCLE) begin
                    clk_counter <= 0;
                    if (bit_counter == 0) begin
                        state <= S_PARITY;
                    end else begin
                        bit_counter <= bit_counter - 1;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
					 $display("Time: %0t | State: S_DONE | clk_counter = %0d, bit_counter = %0d, tx = %0b", $time, clk_counter, bit_counter, tx);

            end
            
            S_PARITY: begin
                if (clk_counter == FINAL_CYCLE) begin
                    clk_counter <= 0;
                    state <= S_STOP;
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end

            S_STOP: begin
                if (clk_counter == FINAL_CYCLE) begin
                    clk_counter <= 0;
                    state <= S_DONE;
                end else begin
                    clk_counter <= clk_counter + 1;
                end
					 if (clk_counter == FINAL_CYCLE - 1)begin
						  tx_done <= 1;
					 end
            end

            S_DONE: begin
                state <= S_IDLE;
            end

            default:
                state <= S_IDLE;
        endcase
    end
    
    //----------------------------------------------------------------------
    // COMBINATIONAL BLOCK: Handles the outputs.
    // This part reacts instantly to changes in state or inputs.
    //----------------------------------------------------------------------
    always @(*) begin
        // By default, tx_done is low. It is only high in the S_DONE state.
        //tx_done = (state == S_DONE);
        
        // This case statement defines the output for each state.
        case(state)
            S_IDLE: begin
                // THIS IS THE FIX: The output 'tx' depends combinatorially
                // on the input 'tx_start'. If we are idle AND tx_start
                // is asserted now, pull tx low immediately. Otherwise, tx is idle (high).
                if (tx_start) begin
                    tx = 1; // Immediate response to start
                end
            end

            S_START:
                tx = 0; // Hold the line low for the Start Bit duration
            
            S_DATA:
                tx = data_reg[bit_counter]; // Output the current data bit
                
            S_PARITY:
                tx = parity_bit_reg; // Output the parity bit
                
            S_STOP, S_DONE:
                tx = 1; // Output the Stop Bit and remain Idle high
                
            default:
                tx = 1;
        endcase
    end

	//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

	endmodule

