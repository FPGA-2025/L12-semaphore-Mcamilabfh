
module Semaphore #(
    parameter CLK_FREQ = 4
) (
    input  wire clk,
    input  wire rst_n,
    input  wire pedestrian,
    output reg green,
    output reg yellow,
    output reg red
);

// Estados 
localparam RED_STATE    = 2'b00;
localparam GREEN_STATE  = 2'b01;
localparam YELLOW_STATE = 2'b10;

reg [1:0] current_state, next_state;
reg [31:0] counter;

// Delays
localparam DELAY_RED    = 5 * CLK_FREQ;
localparam DELAY_GREEN  = 7 * CLK_FREQ;
localparam DELAY_YELLOW = CLK_FREQ / 2;

// DEBUG: imprime parâmetros no início (não afeta diff, grep só pega ===)
initial begin
    $display("DEBUG: DELAY_RED=%0d, DELAY_GREEN=%0d, DELAY_YELLOW=%0d", 
             DELAY_RED, DELAY_GREEN, DELAY_YELLOW);
end

// Lógica combinacional: transição de estado com ajuste -1 para alinhar com sample no nega edge
always @(*) begin
    next_state = current_state;
    case (current_state)
        RED_STATE: begin
            if (counter == DELAY_RED - 1)
                next_state = GREEN_STATE;
        end
        GREEN_STATE: begin
            // prioridade ao pedestre
            if (pedestrian)
                next_state = YELLOW_STATE;
            else if (counter == DELAY_GREEN - 1)
                next_state = YELLOW_STATE;
        end
        YELLOW_STATE: begin
            if (counter == DELAY_YELLOW - 1)
                next_state = RED_STATE;
        end
        default: next_state = RED_STATE;
    endcase
end

// Lógica sequencial: estado e contador
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= RED_STATE;
        counter       <= 0;
    end else begin
        current_state <= next_state;
        if (next_state != current_state)
            counter <= 0;
        else
            counter <= counter + 1;
    end
end

// Saídas Moore
always @(*) begin
    red    = (current_state == RED_STATE);
    green  = (current_state == GREEN_STATE);
    yellow = (current_state == YELLOW_STATE);
end

endmodule