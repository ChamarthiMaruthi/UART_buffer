// EcoMender Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 1MHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_1MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_1MHz,
    input [3:0] pulse_width,
    output reg clk_500Hz,
    output reg pwm_signal
);

initial begin
    clk_500Hz = 1;
    pwm_signal = 1;
end

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

reg [9:0] clk_divider_counter = 10'b0;  // 11-bit counter for clock division
reg [10:0] pwm_counter = 11'b0;  // 11-bit counter for PWM comparison

// Clock division logic to generate 500 Hz clock from 1 MHz
reg toggle_enable = 0;
always @(posedge clk_1MHz) begin
    if (clk_divider_counter == 999) begin
        clk_divider_counter <= 0;
        toggle_enable <= 1;
    end else begin
        clk_divider_counter <= clk_divider_counter + 1'b1;
    end

    if (toggle_enable && clk_divider_counter == 0) begin
        clk_500Hz <= ~clk_500Hz;
    end
end


// PWM signal generation using the 1MHz clock
always @ (posedge clk_1MHz) begin
    pwm_counter <= pwm_counter + 1'b1;
    if (pwm_counter < pulse_width * 100) begin
        pwm_signal <= 1;  // High signal if counter < pulse width
    end else begin
        pwm_signal <= 0;  // Low signal otherwise
    end
    if (pwm_counter == 1999) begin
        pwm_counter <= 0;  // Reset counter after full period (0-1999)
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule