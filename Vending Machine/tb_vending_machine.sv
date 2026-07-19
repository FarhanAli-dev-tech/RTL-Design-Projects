`timescale 1ns/1ps

module tb_vending_machine;

    logic clk;
    logic rst;
    logic [1:0] in;

    logic out;
    logic [1:0] change;

    vending_machine dut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .out(out),
        .change(change)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin

        rst = 1;
        in  = 2'b00;

        #12;
        rst = 0;

        // 5 + 5 = 10
        @(posedge clk) in <= 2'b01;
        @(posedge clk) in <= 2'b01;

        // 10 + 5 => dispense
        @(posedge clk) in <= 2'b01;

        @(posedge clk) in <= 2'b00;

        // Direct 10 + 10 => dispense + change
        @(posedge clk) in <= 2'b10;
        @(posedge clk) in <= 2'b10;

        @(posedge clk) in <= 2'b00;

        #20;
        $finish;

    end

    initial begin

        $display("Time\tState\tIn\tOut\tChange");

        $monitor("%0t\t%b\t%b\t%b\t%b",
                 $time,
                 dut.c_state,
                 in,
                 out,
                 change);

    end

endmodule