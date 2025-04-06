// EcoMender Bot : Task 1B : Color Detection using State Machines
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module that will detect colors red, green, and blue using state machine and frequency detection.
-------------------
*/
// Color Detection
// Inputs : clk_1MHz, cs_out
// Output : filter, color
// Module Declaration
module t1b_cd_fd (
    input clk_1MHz, cs_out,
    output reg [1:0] filter, color
);
// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

// State definitions
localparam S_CLEAR = 2'b10, S_RED = 2'b00, S_GREEN = 2'b11, S_BLUE = 2'b01;

// Internal registers
reg [1:0] state;
reg [8:0] counter;
reg [9:0] frequency_counter;
reg [9:0] gFreq, rFreq, bFreq;
reg [1:0] delayed_filter;  // Register to introduce a precise delay
reg [1:0] delayed_color;   // Register to introduce a precise delay

// Initialize registers
initial begin
    filter = S_GREEN;  // Start with filter value 3 (clear)
    delayed_filter = S_GREEN;  // Initialize delayed_filter
    color = 2'b00;
    delayed_color = 2'b00;
    state = S_GREEN;
    counter = 0;
    frequency_counter = 0;
    gFreq = 0;
    rFreq = 0;
    bFreq = 0;
end

// State machine and filter control
always @(posedge clk_1MHz) begin
    // Increment frequency counter if cs_out is high (representing color sensor output)
    if (cs_out)
        frequency_counter <= frequency_counter + 1;

    case (state)
        S_GREEN: begin
            if (counter == 9'd499) begin  // 500µs period completed
                state <= S_RED;
                delayed_filter <= S_RED;  // Set filter to red
                gFreq <= (frequency_counter>>4);  // Convert to MHz (frequency_counter / 500)
                frequency_counter <= 0;  // Reset frequency counter
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
          
        S_RED: begin
            if (counter == 9'd499) begin  // 500µs period completed
                rFreq <= (frequency_counter>>4);  // Convert to MHz (frequency_counter / 500)
                frequency_counter <= 0;  // Reset frequency counter
                state <= S_BLUE;
                delayed_filter <= S_BLUE;  // Set filter to blue
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end

        S_BLUE: begin
            if (counter == 9'd499) begin  // 500µs period completed
                state <= S_CLEAR;
                delayed_filter <= S_CLEAR;  // Set filter back to clear
                bFreq <= (frequency_counter>>4);  // Convert to MHz (frequency_counter / 500)
                frequency_counter <= 0;  // Reset frequency counter
                counter <= 0;
                
                // Color detection happens at the end of the blue filter state
                if (rFreq > gFreq && rFreq > bFreq) begin
                    delayed_color <= 2'b01;  // Detected color is Red
                    $display("Detected Color value: %b", delayed_color);
                end else if (gFreq > rFreq && gFreq > bFreq) begin
                    delayed_color <= 2'b10;  // Detected color is Green
                    $display("Detected Color value: %b", delayed_color);
                end else if (bFreq > rFreq && bFreq > gFreq) begin
                    delayed_color <= 2'b11;  // Detected color is Blue
                    $display("Detected Color value: %b", delayed_color);
                end else begin
                    delayed_color <= 2'b00;  // No clear color detected
                    $display("Detected Color value: %b", delayed_color);
                end
					 /* Print RGB frequency
                $display("Red Frequency: %d", rFreq);
                $display("Green Frequency: %d", gFreq);
                $display("Blue Frequency: %d", bFreq); */
            end else begin
                counter <= counter + 1;
            end
        end

        S_CLEAR: begin
            if (counter == 9'd0) begin  // 1µs period completed
                state <= S_GREEN;
                delayed_filter <= S_GREEN;  // Set filter to green
                frequency_counter <= 0;  // Reset frequency counter
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end

        default: state <= S_CLEAR;
    endcase
end

// Delayed filter and color output (for simulation only)
always @(posedge clk_1MHz) begin
    filter <= delayed_filter;  // 1 clock cycle delay
    color <= delayed_color;   // 1 clock cycle delay
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////
endmodule