`timescale 1ns/1ps

module tb_fifo;

    logic clk;
    logic rst;

    logic wr_en;
    logic rd_en;

    logic [7:0] data_in;
    logic [7:0] data_out;

    logic full;
    logic empty;

    fifo_8bit dut(
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        #12 rst = 0;

        // Write
        @(posedge clk) begin wr_en<=1; data_in<=8'h11; end
        @(posedge clk) begin wr_en<=1; data_in<=8'h22; end
        @(posedge clk) begin wr_en<=1; data_in<=8'h33; end

        @(posedge clk) wr_en<=0;

        // Read
        @(posedge clk) rd_en<=1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        rd_en<=0;

        #20;
        $finish;
    end

endmodule