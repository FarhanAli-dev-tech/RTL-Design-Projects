module tb_ps2_receiver;
    logic clk;
    logic rst;

    logic ps2_data;
    logic ps2_valid;

    logic [7:0] scan_code;
    logic parity_error;
    logic frame_error;
    logic data_ready;

    ps2_receiver dut (
        .clk(clk),
        .rst(rst),
        .ps2_data(ps2_data),
        .ps2_valid(ps2_valid),
        .scan_code(scan_code),
        .parity_error(parity_error),
        .frame_error(frame_error),
        .data_ready(data_ready)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    task send_frame(
        input [7:0] data,
        input parity,
        input stop
    );
        integer i;
        begin
            // Start Bit = 0
            @(posedge clk);
            ps2_valid <= 1;
            ps2_data  <= 0;

            // Data Bits (LSB First)
            for(i=0;i<8;i=i+1)
            begin
                @(posedge clk);
                ps2_data <= data[i];
            end

            // Parity Bit
            @(posedge clk);
            ps2_data <= parity;

            // Stop Bit
            @(posedge clk);
            ps2_data <= stop;

            @(posedge clk);
            ps2_valid <= 0;
        end
    endtask
    initial begin
        rst = 1;
        ps2_valid = 0;
        ps2_data  = 1;

        #20;
        rst = 0;
        send_frame(
            8'h1C,
            ~(^8'h1C),   // odd parity
            1'b1
        );
        #50;
        send_frame(
            8'h2E,
            ~(^8'h2E),
            1'b1
        );
        #50;
        send_frame(
            8'h55,
            ~(^8'h55),
            1'b1
        );

        #50;


        send_frame(
            8'h1C,
            (^8'h1C),    // intentionally wrong
            1'b1
        );

        #50;
        send_frame(
            8'h1C,
            ~(^8'h1C),
            1'b0
        );

        #50;
        $finish;
    end
endmodule