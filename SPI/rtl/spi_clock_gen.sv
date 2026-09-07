    module spi_clock_gen (
        input logic clk,
        input logic rstn,
        input logic sclk_en,
        output logic sclk,
        output logic rising_edge,
        output logic falling_edge
    );

        logic [2:0] counter;

        always_ff @(posedge clk or negedge rstn) begin
            if(!rstn) begin
                rising_edge <= 0;
                falling_edge <= 0;
                counter <= '0;
                sclk <= 0;
            end else if (!sclk_en) begin
                counter <= '0;
                sclk <= 0;
                rising_edge <= 0;
                falling_edge <= 0;
            end else begin
                if (counter == 3'd3) begin
                    sclk <= ~sclk;
                    counter <= '0;
                    rising_edge <= (sclk == 0);
                    falling_edge <= (sclk == 1);
                end else begin
                    counter <= counter + 1'b1;
                    rising_edge <= 0;
                    falling_edge <= 0;
                end
            end
        end 


    endmodule