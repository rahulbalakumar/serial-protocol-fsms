module tb_spi_fsm;
    logic clk;
    logic rstn;
    logic start;
    logic rising_edge;
    logic falling_edge;
    logic bit_count_done;
    logic cs;
    logic sclk_en;
    logic load;
    logic sample_en;
    logic shift_en;
    logic busy;

    spi_fsm dut (.*);

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
        start = 0;
        rising_edge = 0;
        falling_edge = 0;
        bit_count_done = 0;
        @(posedge clk);
        #1;
        start = 1;
        #1;
        assert (load == 1)
        else $error("Load is not 1, it should be 1");
        @(posedge clk);
        #1;
        start = 0;
        #1;
        assert (busy == 1)
        else $error("Busy is not 1, it should be 1");
        @(posedge clk);
        #1;
        start = 1;
        #1;
        assert (load == 0)
        else $error("Load is not 0, it should be 0");
        @(posedge clk);
        #1;
        start = 0;
        #1;
        assert (busy == 1)
        else $error("Busy is not 1, FSM must be in TRANSFER!");
        @(posedge clk);
        #1;
        rising_edge = 1;
        #1;
        assert (sample_en == 1)
        else $error("Sample Enable should be 1");
        assert (shift_en == 0)
        else $error("Shift enable should be 0");
        @(posedge clk);
        #1;
        rising_edge = 0;
        falling_edge = 1;
        #1;
        assert (shift_en == 1)
        else $error("Shift Enable should be 1");
        assert (sample_en == 0)
        else $error("Sample Enable should be 0");
        @(posedge clk);
        #1;
        falling_edge = 0;
        #1;
        bit_count_done = 1;
        @(posedge clk);
        #1;
        rising_edge = 1;
        #1;
        assert (busy == 1)
        else $error("Busy should be 1");
        @(posedge clk);
        #1;
        rising_edge = 0;
        falling_edge = 1;
        #1;
        assert (shift_en == 1)
        else $error("Shift enable should be 1");
        @(posedge clk);
        #1;
        assert (busy == 0)
        else $error("Busy should be 0");
        assert (cs == 1)
        else $error("cs should be 1");
        $display("All tests passed!");
        $finish();
    end

endmodule