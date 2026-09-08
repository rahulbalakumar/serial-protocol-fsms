module spi_top (
    input logic clk,
    input logic rstn,
    input logic start,
    input logic [7:0] tx_data,
    input logic miso,
    output logic sclk,
    output logic mosi,
    output logic cs,
    output logic busy,
    output logic [7:0] rx_data
);
    logic bit_count_done;
    logic load;
    logic rising_edge;
    logic falling_edge;
    logic sclk_en;
    logic sample_en;
    logic shift_en;
    
    spi_clock_gen clock (.clk(clk),
                         .rstn(rstn),
                         .sclk_en(sclk_en),
                         .sclk(sclk),
                         .rising_edge(rising_edge),
                         .falling_edge(falling_edge));

    spi_fsm fsm (.clk(clk),
                 .rstn(rstn),
                 .start(start),
                 .rising_edge(rising_edge),
                 .falling_edge(falling_edge),
                 .bit_count_done(bit_count_done),
                 .cs(cs),
                 .sclk_en(sclk_en),
                 .load(load),
                 .sample_en(sample_en),
                 .shift_en(shift_en),
                 .busy(busy));

    spi_shift_reg register (.clk(clk),
                       .rstn(rstn),
                       .load(load),
                       .shift_en(shift_en),
                       .tx_data(tx_data),
                       .miso(miso),
                       .mosi(mosi),
                       .rx_data(rx_data),
                       .bit_count_done(bit_count_done));
    
endmodule
