module tb_spi_shift_reg;
    logic clk;
    logic rstn;
    logic load;
    logic shift_en;
    logic [7:0] tx_data;
    logic miso;
    logic mosi;
    logic [7:0] rx_data;
    logic bit_count_done;

    spi_shift_reg dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
        rstn = 0;
        load = 0;
        shift_en = 0;
        tx_data = '0;
        miso = 0;
        #1;
        rstn = 1;
    end

    initial begin
        @(posedge clk);
        #1;
        tx_data = 8'd250;
        load = 1;
        @(posedge clk);
        #1;
        load = 0;
        assert(rx_data == 8'd250)
        else $error("Shift register didn't load correctly.");
        assert(mosi == 1'b1)
        else $error("MOSI is wrong.");
        miso = 1'b1;
        shift_en = 1'b1;
        @(posedge clk);
        #1;
        assert(rx_data == 8'd245)
        else $error("Shifting didn't happen correctly.");
        assert(mosi == 1'b1)
        else $error("MOSI is wrong after the shifting.");
        repeat (7) @(posedge clk);
        #1;
        assert (bit_count_done == 1)
        else $error("Bit count done is 0 after a full byte shifting.");
        assert (rx_data == 8'd255)
        else $error("rx_data should be 255.");
        $display("Simulation is finished.");
        $finish();
    end
endmodule