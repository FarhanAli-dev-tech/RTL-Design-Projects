module tb_seq1101_moore;

    logic clk;
    logic rst;
    logic din;
    logic detected;

    // DUT
    seq1101_moore dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .detected(detected)
    );

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin

        rst = 1;
        din = 0;

        #12;
        rst = 0;

        // Sequence: 1101101
        @(posedge clk) din <= 1;
        @(posedge clk) din <= 1;
        @(posedge clk) din <= 0;
        @(posedge clk) din <= 1; // First detection

        @(posedge clk) din <= 1;
        @(posedge clk) din <= 0;
        @(posedge clk) din <= 1; // Second detection (overlap)

        @(posedge clk) din <= 0;
        @(posedge clk) din <= 0;

        #20;
        $finish;
    end

    // Monitor
    initial begin
        $display("Time\tclk\trst\tdin\tdetected");
        $monitor("%0t\t%b\t%b\t%b\t%b",
                 $time, clk, rst, din, detected);
    end

endmodule