module tb_spi_clock_gen;
    logic clk;
    logic rstn;
    logic sclk_en;
    logic sclk;
    logic rising_edge;
    logic falling_edge;

    spi_clock_gen dut (.*);

    initial begin // Clock Driver
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin // Assertion of Reset
        rstn = 0;
        #1;
        rstn = 1;
    end

    initial begin
        $dumpfile("dump.vcd");$dumpvars(0,dut);
    end

    initial begin
        sclk_en = 0;
        @(posedge clk);
        #1;
        assert (sclk == 0)
        else $error("sclk should be 0");
        sclk_en = 1;
        repeat (4) @(posedge clk);
        #1;
        assert (rising_edge == 1)
        else $error("Rising Edge should be 1 at 4th clock cycle");
        repeat (4) @(posedge clk);
        #1;
        assert (falling_edge == 1)
        else $error("Falling Edge should be 1 at 8th clock cycle.");
        @(posedge clk);
        #1;
        $finish();

    end

endmodule