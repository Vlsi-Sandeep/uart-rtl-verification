module uart_top (
    input  wire       clk,
    input  wire       reset,
    input  wire       send,
    input  wire [7:0] data_in,

    output wire       tx,
    output wire [7:0] data_out,
    output wire       busy,
    output wire       done
);

    wire tick;
    wire rx_serial;

    // --------------------------------
    // Baud tick generator
    // --------------------------------
    baud_tick baud_gen (
        .clk   (clk),
        .reset (reset),
        .tick  (tick)
    );


    // --------------------------------
    // UART TX
    // --------------------------------
    uart_tx transmitter (
        .clk   (clk),
        .reset (reset),
        .tick  (tick),
        .send  (send),
        .data  (data_in),
        .tx    (tx),
        .busy  (busy),
        .done  ()
    );


    // --------------------------------
    // Connect TX directly to RX
    // --------------------------------
    assign rx_serial = tx;


    // --------------------------------
    // UART RX
    // --------------------------------
    uart_rx receiver (
        .clk   (clk),
        .reset (reset),
        .tick  (tick),
        .rx    (rx_serial),
        .data  (data_out),
        .busy  (),
        .done  (done)
    );

endmodule
