module traffic_light_fsm (
    input  logic clk,
    input  logic rst,

    output logic red,
    output logic yellow,
    output logic green
);

    typedef enum logic [1:0] {
        RED_STATE     = 2'b00,
        YELLOW1_STATE = 2'b01,
        GREEN_STATE   = 2'b10,
        YELLOW2_STATE = 2'b11
    } state_t;

    state_t state, next_state;

    // State Register (changes only on posedge clk)
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= RED_STATE;
        else
            state <= next_state;
    end

    // Next-State Logic
    always_comb begin
        case (state)

            RED_STATE:
                next_state = YELLOW1_STATE;

            YELLOW1_STATE:
                next_state = GREEN_STATE;

            GREEN_STATE:
                next_state = YELLOW2_STATE;

            YELLOW2_STATE:
                next_state = RED_STATE;

            default:
                next_state = RED_STATE;

        endcase
    end

    // Output Logic (Moore FSM)
    always_comb begin
        red    = 1'b0;
        yellow = 1'b0;
        green  = 1'b0;

        case (state)

            RED_STATE:
                red = 1'b1;

            YELLOW1_STATE,
            YELLOW2_STATE:
                yellow = 1'b1;

            GREEN_STATE:
                green = 1'b1;

            default: begin
                red    = 1'b0;
                yellow = 1'b0;
                green  = 1'b0;
            end

        endcase
    end

endmodule