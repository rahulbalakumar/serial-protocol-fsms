module spi_fsm (
    input logic clk,
    input logic rstn,
    input logic start,
    input logic rising_edge,
    input logic falling_edge,
    input logic bit_count_done,
    output logic cs,
    output logic sclk_en,
    output logic load,
    output logic sample_en,
    output logic shift_en,
    output logic busy
);

    typedef enum logic { // Defining FSM
        IDLE,
        TRANSFER
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rstn) begin // State Register
        if (!rstn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin // FSM next state logic
        next_state = state;

        case(state)
            IDLE: begin
                if (start) begin
                    next_state = TRANSFER;
                end
            end
            
            TRANSFER: begin
                if (falling_edge && bit_count_done) begin
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end

    always_comb begin // Moore FSM
        cs = (state == IDLE);
        sclk_en = (state == TRANSFER);
        busy = (state == TRANSFER);
    end

    always_comb begin // Mealy FSM
        load = 0;
        sample_en = 0;
        shift_en = 0;

        case(state)
            IDLE : begin
                if (start) begin
                    load = 1;
                end
            end

            TRANSFER : begin
                if (rising_edge) begin
                    sample_en = 1;
                end

                if (falling_edge) begin
                    shift_en = 1;
                end
            end

            default : ;
        endcase
    end
endmodule