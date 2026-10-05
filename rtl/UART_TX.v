module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       tick,
    input  wire       send,
    input  wire [7:0] data,

    output reg        tx,
    output reg        busy,
    output reg        done
);

    // Stores the byte currently being transmitted
    reg [7:0] shift_reg;

    // Counts the 8 data bits
    reg [3:0] bit_count;

    // UART state
    reg [1:0] state;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;


    always @(posedge clk) begin

        if (reset) begin

            tx        <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            shift_reg <= 8'd0;
            bit_count <= 4'd0;
            state     <= IDLE;

        end

        else begin

            // done is normally LOW.
            // It becomes HIGH for one clock when transmission finishes.
            done <= 1'b0;


            case (state)

                // --------------------------------
                // IDLE STATE
                // --------------------------------
                IDLE: begin

                    tx   <= 1'b1;
                    busy <= 1'b0;

                    if (send) begin

                        // Copy input data into shift register
                        shift_reg <= data;

                        // Start from data bit 0
                        bit_count <= 4'd0;

                        // Transmission has started
                        busy <= 1'b1;

                        // Go to START state
                        state <= START;

                    end

                end


                // --------------------------------
                // START BIT
                // --------------------------------
                START: begin

                    if (tick) begin

                        // UART start bit = 0
                        tx <= 1'b0;

                        // Next state = DATA
                        state <= DATA;

                    end

                end


                // --------------------------------
                // DATA BITS
                // --------------------------------
                DATA: begin

                    if (tick) begin

                        // Send LSB first
                        tx <= shift_reg[0];

                        // Shift next bit into bit 0
                        shift_reg <= shift_reg >> 1;


                        if (bit_count == 4'd7) begin

                            // All 8 data bits are complete
                            bit_count <= 4'd0;

                            // Go to STOP state
                            state <= STOP;

                        end

                        else begin

                            // Move to next data bit
                            bit_count <= bit_count + 1'b1;

                        end

                    end

                end


                // --------------------------------
                // STOP BIT
                // --------------------------------
                STOP: begin

                    if (tick) begin

                        // UART stop bit = 1
                        tx <= 1'b1;

                        // Transmission finished
                        busy <= 1'b0;

                        // Generate one-clock done pulse
                        done <= 1'b1;

                        // Return to IDLE
                        state <= IDLE;

                    end

                end

            endcase

        end

    end

endmodule
