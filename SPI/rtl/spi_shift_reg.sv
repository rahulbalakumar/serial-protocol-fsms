module spi_shift_reg (
    input logic clk,
    input logic rstn,
    input logic load,
    input logic shift_en,
    input logic [7:0] tx_data,
    input logic miso,
    output logic mosi,
    output logic [7:0] rx_data,
    output logic bit_count_done
);

    logic [7:0] shift_reg;
    logic [2:0] bit_count;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            shift_reg <= '0;
            bit_count <= '0;
        end else if (load) begin
            shift_reg <= tx_data;
            bit_count <= '0;
        end else if (shift_en) begin
            shift_reg <= {shift_reg[6:0],miso};
            bit_count <= bit_count + 1;
        end
    end

    always_comb begin
        mosi = shift_reg[7];
        rx_data = shift_reg;
        bit_count_done = (bit_count == 3'd7);
    end
endmodule