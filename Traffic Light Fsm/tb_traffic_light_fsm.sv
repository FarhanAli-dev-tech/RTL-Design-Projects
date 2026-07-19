`timescale 1ns/1ps

module tb_traffic_light_fsm;

    logic clk;
    logic rst;

    logic red;
    logic yellow;
    logic green;

    traffic_light_fsm dut (
        .clk(clk),
        .rst(rst),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin

        rst = 1'b1;

        #12;
        rst = 1'b0;

        repeat (10)
            @(posedge clk);

        $finish;
    end

    // Monitor
    initial begin
        $display("Time\tState of Lights");
        $monitor("%0t\tR=%b Y=%b G=%b",
                 $time, red, yellow, green);
    end

endmodule