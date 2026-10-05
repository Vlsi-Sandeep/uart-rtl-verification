`timescale 1ns/1ps

module uart_top_tb;

    reg clk;
    reg reset;
    reg send;
    reg [7:0] data_in;

    wire tx;
    wire [7:0] data_out;
    wire busy;
    wire done;


    // ------------------------------------------------
    // UART TOP
    // ------------------------------------------------

    uart_top uut (
        .clk      (clk),
        .reset    (reset),
        .send     (send),
        .data_in  (data_in),
        .tx       (tx),
        .data_out (data_out),
        .busy     (busy),
        .done      (done)
    );


    // ------------------------------------------------
    // CLOCK
    // ------------------------------------------------

    always #50 clk = ~clk;


    // ------------------------------------------------
    // TASK: SEND AND CHECK ONE BYTE
    // ------------------------------------------------

    task send_byte;

        input [7:0] test_data;

        begin

            // Put data on input
            data_in = test_data;

            // Tell UART to start
            send = 1'b1;

            #100;

            // Remove send command
            send = 1'b0;

            // Wait until UART finishes
            wait(done == 1'b1);


            // Check received data
            if (data_out == test_data) begin

                $display("PASS: Sent = %h, Received = %h",
                         test_data, data_out);

            end

            else begin

                $display("FAIL: Sent = %h, Received = %h",
                         test_data, data_out);

            end

            // Small gap before next test
            #500;

        end

    endtask


    // ------------------------------------------------
    // MAIN TEST
    // ------------------------------------------------

    initial begin

        clk     = 1'b0;
        reset   = 1'b1;
        send    = 1'b0;
        data_in = 8'h00;


        // Reset
        #200;
        reset = 1'b0;


        // ------------------------------------------------
        // MULTIPLE TESTS
        // ------------------------------------------------

        send_byte(8'h41);

        send_byte(8'h55);

        send_byte(8'hAA);

        send_byte(8'h00);

        send_byte(8'hFF);


        // ------------------------------------------------
        // FINISH
        // ------------------------------------------------

        $display("--------------------------------");
        $display("ALL TESTS COMPLETED");
        $display("--------------------------------");

        #500;

        $stop;

    end

endmodule
