module ps2_receiver (

    input  logic clk,
    input  logic rst,

    input  logic ps2_data,
    input  logic ps2_valid,

    output logic [7:0] scan_code,
    output logic parity_error,
    output logic frame_error,
    output logic data_ready

);

    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP,
        CHECK
    } state_t;

    state_t state,next_state;

    logic [7:0] shift_reg;
    logic [3:0] bit_count;

    logic parity_bit;
    logic stop_bit;

    //=========================
    // State Register
    //=========================
    always_ff @(posedge clk or posedge rst) begin

        if(rst)
        begin
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= 0;
        end
        else
        begin

            state <= next_state;

            case(state)

                DATA:
                begin
                    if(ps2_valid)
                    begin
                        shift_reg[bit_count] <= ps2_data;
                        bit_count <= bit_count + 1;
                    end
                end

                PARITY:
                    parity_bit <= ps2_data;

                STOP:
                    stop_bit <= ps2_data;

            endcase
        end
    end

    //=========================
    // Next State Logic
    //=========================
    always_comb begin

        next_state = state;

        case(state)

            IDLE:
                if(ps2_valid && ps2_data==0)
                    next_state = START;

            START:
                next_state = DATA;

            DATA:
                if(bit_count == 8)
                    next_state = PARITY;

            PARITY:
                next_state = STOP;

            STOP:
                next_state = CHECK;

            CHECK:
                next_state = IDLE;

        endcase

    end

    //=========================
    // Output Logic
    //=========================
    always_comb begin

        parity_error = 0;
        frame_error  = 0;
        data_ready   = 0;

        scan_code = shift_reg;

        if(state == CHECK)
        begin

            // Stop bit check
            if(stop_bit != 1'b1)
                frame_error = 1;

            // Odd parity check
            else if(^shift_reg != ~parity_bit)
                parity_error = 1;

            else
            begin

                case(shift_reg)

                    8'h45, //0
                    8'h16, //1
                    8'h1E, //2
                    8'h26, //3
                    8'h25, //4
                    8'h2E, //5
                    8'h36, //6
                    8'h3D, //7
                    8'h3E, //8
                    8'h46, //9
                    8'h1C, //A
                    8'h32, //B
                    8'h21, //C
                    8'h23, //D
                    8'h24, //E
                    8'h2B: //F
                        data_ready = 1;

                    default:
                        frame_error = 1;

                endcase

            end

        end

    end

endmodule