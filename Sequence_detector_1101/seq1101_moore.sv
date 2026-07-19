module seq1101_moore (
    input  logic clk,
    input  logic rst,
    input  logic din,
    output logic detected
);

    typedef enum logic [2:0] {
        S0, // No match
        S1, // 1
        S2, // 11
        S3, // 110
        S4  // 1101 detected
    } state_t;

    state_t state, next_state;

    // State Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-State Logic
    always_comb begin
        next_state = state; // default

        case (state)

            S0: begin
                if (din)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
                if (din)
                    next_state = S2;
                else
                    next_state = S0;
            end

            S2: begin
                if (din)
                    next_state = S2; // still have "11"
                else
                    next_state = S3; // got "110"
            end

            S3: begin
                if (din)
                    next_state = S4; // got "1101"
                else
                    next_state = S0;
            end

            S4: begin
                if (din)
                    next_state = S2; // overlap handling
                else
                    next_state = S0;
            end

            default:
                next_state = S0;

        endcase
    end

    // Moore Output Logic
    always_comb begin
        detected = (state == S4);
    end

endmodule