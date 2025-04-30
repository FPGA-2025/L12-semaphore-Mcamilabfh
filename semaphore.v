module Semaphore #(
    parameter CLK_FREQ = 25_000_000
) (
    input  wire clk,
    input  wire rst_n,
    input  wire pedestrian,
    output reg green,
    output reg yellow,
    output reg red
);

// Estados como constantes
localparam RED_STATE    = 2'b00;
localparam GREEN_STATE  = 2'b01;
localparam YELLOW_STATE = 2'b10;

// Registradores de estado
reg [1:0] current_state, next_state;


// Contador de tempo
reg [31:0] counter;

// Parâmetro de tempo
localparam DELAY_RED = 5 * CLK_FREQ;
localparam DELAY_GREEN = 7 * CLK_FREQ;
localparam DELAY_YELLOW = CLK_FREQ / 2;

//Atualização do estado e do contador

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

        current_state <= RED_STATE;
        counter <= 0;
     
    end else begin
        
        current_state <= next_state;
    
    if (current_state != next_state)

        counter <= 0;
    
    else

        counter <= counter + 1;

    end
end

//Lógica de transição de estado
always @(*) begin
next_state = current_state;

case (current_state)
        RED_STATE: begin
            if (counter >= DELAY_RED)
            next_state = GREEN_STATE;
        end
        GREEN_STATE: begin
            if (pedestrian || counter >= DELAY_GREEN)
            next_state = YELLOW_STATE;

        end

        YELLOW_STATE: begin
            if (counter >= DELAY_YELLOW)
            next_state = RED_STATE;

        end
        default: next_state = RED_STATE; // Segurança
    endcase
end

//Saídas baseadas no estado (Moore)
    always @(*) begin
        red = (current_state == RED_STATE);
        green = (current_state == GREEN_STATE);
        yellow = (current_state == YELLOW_STATE);
    end
endmodule