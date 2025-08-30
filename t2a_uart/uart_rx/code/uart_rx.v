// EcoMender Bot : Task 2A - UART Receiver
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to receive UART Rx data packet from receiver line and then update the rx_msg and rx_complete data lines.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Receiver

Baudrate: 230400 

Input:  clk_3125 - 3125 KHz clock
        rx      - UART Receiver

Output: rx_msg - received input message of 8-bit width
        rx_parity - received parity bit
        rx_complete - successful uart packet processed signal
*/

// module declaration
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

initial begin
    rx_msg = 0;
	  rx_parity = 0;
    rx_complete = 0;
end

// Add your code here....

// --- Parameters and State Definitions ---
    localparam CLOCKS_PER_BIT = 14;
    localparam FINAL_CYCLE    = 13;

    // YOUR OPTIMIZED FSM: S_START is the combined IDLE/START state.
	 localparam S_IDLE   = 3'b000;
    localparam S_START  = 3'b001;
    localparam S_DATA   = 3'b010;
    localparam S_PARITY = 3'b011;
    localparam S_STOP   = 3'b100;
    
    // --- Internal Registers ---
    reg [2:0] state = S_IDLE;
    reg [4:0] clk_counter = 0;
    reg [2:0] bit_counter = 7;
    reg [7:0] data_shift_reg=0;
	 reg rx_start, sampled_parity;


always @(posedge clk_3125) begin
rx_complete = 0;

case(state)

				S_IDLE : begin
					 if (rx == 0) begin
						state <= S_START;
					 end
					 else begin
						state <= S_IDLE;
					 end
				end
					
            S_START: begin
                    if (clk_counter == 6) begin
                        clk_counter <= 0;
                        bit_counter <= 7; // Prepare to receive MSB first
								if(rx == 0)begin
								rx_start <= rx;
                        state <= S_DATA;
								end else begin
								clk_counter <= 0;
								state <= S_IDLE;
								end
								$display("Time: %t | S_START -> Sampling Start Bit. Waited %d cycles. rx value: %b", $time, clk_counter + 1, rx);
                    end else begin
                        clk_counter <= clk_counter + 1;
                    end
            end
            
            S_DATA: begin
                if (clk_counter == FINAL_CYCLE) begin
                    // On the last clock tick, sample the RX line for the data bit.
						  data_shift_reg <= {data_shift_reg[6:0],rx};
                    //data_shift_reg[bit_counter] <= rx;
                    clk_counter <= 0;
						  $display("Time: %t | S_DATA  -> Sampling data bit[%d]. Waited %d cycles. rx value: %b", $time, bit_counter, clk_counter + 1, rx);
                    if (bit_counter == 0) begin // Finished with the LSB
                        state <= S_PARITY;
                    end else begin
                        bit_counter <= bit_counter - 1;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end

            S_PARITY: begin
                if (clk_counter == FINAL_CYCLE) begin
                    sampled_parity <= rx; // Sample the parity bit
                    clk_counter <= 0;
                    state <= S_STOP;
						  $display("Time: %t | S_PARITY-> Sampling Parity Bit. Waited %d cycles. rx value: %b", $time, clk_counter + 1, rx);
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end

            S_STOP : begin
					if (clk_counter == 20) begin
						clk_counter <= 1;
						rx_msg[7:0] <= data_shift_reg[7:0];
						rx_complete <= rx;
						rx_parity <= sampled_parity;
						state <= S_IDLE;
						$display("Time: %t | S_STOP  -> Sampling Stop Bit. Waited %d cycles. rx value: %b. FRAME COMPLETE.", $time, clk_counter + 1, rx);
					end 
					else begin
                  clk_counter <= clk_counter + 1;
					end
				end

            default:
                state <= S_IDLE;
        endcase
    end

endmodule

