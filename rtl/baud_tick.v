module baud_tick (
    input  wire clk,
    input  wire reset,
    output reg tick
);

    reg [3:0] count;

    always @(posedge clk) begin

        if (reset) begin
            count <= 4'd0;
            tick  <= 1'b0;
        end

        else begin

            if (count == 4'd9) begin
                count <= 4'd0;
                tick  <= 1'b1;
            end

            else begin
                count <= count + 1'b1;
                tick  <= 1'b0;
            end

        end

    end

endmodule
