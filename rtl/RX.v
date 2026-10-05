module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       tick,
    input  wire       rx,

    output reg [7:0]  data,
    output reg       busy,
    output reg       done
);

    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [1:0] state;

    // Counts clock cycles for RX sampling
    reg [3:0] sample_count;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    always @(posedge clk) begin

        if (reset) begin

            data         <= 8'd0;
            busy         <= 1'b0;
            done         <= 1'b0;
            shift_reg    <= 8'd0;
            bit_count    <= 4'd0;
            sample_count <= 4'd0;
            state        <= IDLE;

        end

        else begin

            // done is only a one-clock pulse
            done <= 1'b0;

            case (state)

                // --------------------------------
                // IDLE
                // --------------------------------
                IDLE: begin

                    busy <= 1'b0;

                    if (rx == 1'b0) begin

                        busy         <= 1'b1;
                        bit_count    <= 4'd0;
                        sample_count <= 4'd0;
                        state        <= START;

                    end

                end


                // --------------------------------
                // START
                // Wait half a bit and verify
                // the start bit
                // --------------------------------
                START: begin

                    if (sample_count == 4'd4) begin

                        sample_count <= 4'd0;

                        if (rx == 1'b0) begin

                            state <= DATA;

                        end

                        else begin

                            // False start
                            state <= IDLE;
                            busy  <= 1'b0;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 1'b1;

                    end

                end


                // --------------------------------
                // DATA
                // Sample one bit every 10 clocks
                // --------------------------------
                DATA: begin

                    if (sample_count == 4'd9) begin

                        sample_count <= 4'd0;

                        shift_reg[bit_count] <= rx;

                        if (bit_count == 4'd7) begin

                            bit_count <= 4'd0;
                            state     <= STOP;

                        end

                        else begin

                            bit_count <= bit_count + 1'b1;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 1'b1;

                    end

                end


                // --------------------------------
                // STOP
                // --------------------------------
                STOP: begin

                    if (sample_count == 4'd9) begin

                        sample_count <= 4'd0;

                        if (rx == 1'b1) begin

                            data <= shift_reg;
                            done <= 1'b1;

                        end

                        busy  <= 1'b0;
                        state <= IDLE;

                    end

                    else begin

                        sample_count <= sample_count + 1'b1;

                    end

                end

            endcase

        end

    end

endmodule
