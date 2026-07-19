module vending_machine (
    input  logic       clk,
    input  logic       rst,
    input  logic [1:0] in,      // 00=no coin, 01=5Rs, 10=10Rs

    output logic       out,
    output logic [1:0] change

);
    typedef enum logic [1:0] {
        S0 = 2'b00,   // Rs 0
        S1 = 2'b01,   // Rs 5
        S2 = 2'b10    // Rs 10
    } state_t;

    state_t c_state, n_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            c_state <= S0;
        else
            c_state <= n_state;
    end

    always_comb begin
        n_state = c_state;
        out     = 1'b0;
        change  = 2'b00;

        case (c_state)
            S0: begin
                case (in)
                    2'b00: begin
                        n_state = S0;
                    end

                    2'b01: begin
                        n_state = S1;
                    end

                    2'b10: begin
                        n_state = S2;
                    end

                    default: begin
                        n_state = S0;
                    end
                endcase
            end
            S1: begin
                case (in)
                    2'b00: begin
                        n_state = S0;
                        change  = 2'b01; // return 5 Rs
                    end

                    2'b01: begin
                        n_state = S2;
                    end

                    2'b10: begin
                        n_state = S0;
                        out     = 1'b1;
                    end

                    default: begin
                        n_state = S1;
                    end
                endcase
            end

            S2: begin
                case (in)
                    2'b00: begin
                        n_state = S0;
                        change  = 2'b10; // return 10 Rs
                    end

                    2'b01: begin
                        n_state = S0;
                        out     = 1'b1;
                    end

                    2'b10: begin
                        n_state = S0;
                        out     = 1'b1;
                        change  = 2'b01; // return 5 Rs
                    end

                    default: begin
                        n_state = S2;
                    end
                endcase
            end

            default: begin
                n_state = S0;
                out     = 1'b0;
                change  = 2'b00;
            end
        endcase
    end
endmodule
