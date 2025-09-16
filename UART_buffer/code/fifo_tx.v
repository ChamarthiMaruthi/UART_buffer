module fifo_tx #(
    parameter DEPTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input              clk_3125_tx,  // Clock
    input              reset,        // Synchronous reset
    input              wr_en,        // Write enable
    input              rd_en,        // Read enable
    input      [7:0]   ft_data,      // Data input
    output             ft_full,      // FIFO full status
    output             ft_empty,     // FIFO empty status
    output reg [7:0]   ft_out        // Data output (registered)
);

    // --- Internal Storage ---
    reg [7:0] mem [0:DEPTH-1];

    // --- Pointers (with extra bit for full/empty detection) ---
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    initial begin
		wr_ptr     = 0;
      rd_ptr     = 0;
    end

	 // --- Status Logic ---
    assign ft_empty = (wr_ptr == rd_ptr);
    assign ft_full  = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);
	 
    // --- FIFO Logic ---
    always @(posedge clk_3125_tx) begin
        if (reset) begin
            wr_ptr     <= 0;
            rd_ptr     <= 0;
            ft_out     <= 0;
            //dout_valid <= 0;
				/*$display("FIFO RESET: time=%0t wr_ptr=%0d rd_ptr=%0d ft_empty=%b",
             $time, wr_ptr, rd_ptr, (wr_ptr==rd_ptr));*/
        end else begin
            // -----------------------
            // Write Operation
            // -----------------------
            if (wr_en) begin
					 //$display("ft_data : %b",ft_data);
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= ft_data;
                wr_ptr <= wr_ptr + 1;
                /*$display("FIFO WRITE: time=%0t data=%02h wr_ptr=%0d -> new_wr_ptr=%0d ft_full=%b ft_empty(before)=%b",
             $time, ft_data, wr_ptr, wr_ptr+1, ft_full, (wr_ptr==rd_ptr));*/
            end

            // -----------------------
            // FWFT Read Operation
            // -----------------------
            if (rd_en && !ft_empty) begin
                if (ft_empty == 0) begin
						  //$display("Time : %t,ft_empty : %b",$time,ft_empty);
                    // Still more data left, load next word
						  //$display("FIFO CONSUME+LOAD: time=%0t rd_en=1 dout(valid) before=%02h -> next=%02h rd_ptr=%0d -> %0d wr_ptr=%0d",
                    //$time, ft_out, mem[rd_ptr[ADDR_WIDTH-1:0]], rd_ptr, rd_ptr+1, wr_ptr);
                    ft_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                    rd_ptr <= rd_ptr + 1;
                    //$display("Time %0t: FIFO Next Output -> %02h (rd_ptr=%0d)", $time, ft_out, rd_ptr);
                end 
            end
        end
    end

endmodule
