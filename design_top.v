`timescale 1ns / 1ps

module uart_rx(
    input clk_fpga,
    input reset,
    input rxd,
    output reg [7:0] Rx_data
);
    reg shift;
    reg state, next_state;
    reg [3:0] bit_counter;
    reg [1:0] sample_counter;
    reg [13:0] baud_counter;
    reg [9:0] rx_shiftreg;
    reg clear_bitcounter, inc_bitcounter, inc_samplecounter, clear_samplecounter;

    parameter clk_freq = 50000000;   // 50 MHz FPGA clock
    parameter baud_rate = 9600;
    parameter div_sample = 4;
    parameter div_counter = 1302;  // baud counter
    parameter mid_sample = div_sample/2;
    parameter div_bit = 10;  // 1 start + 8 data + 1 stop

    always @(posedge clk_fpga or posedge reset) begin
        if (reset) begin
            state <= 0;
            bit_counter <= 0;
            baud_counter <= 0;
            sample_counter <= 0;
            rx_shiftreg <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
            
            if (baud_counter >= div_counter-1) begin
                baud_counter <= 0;
                state <= next_state;
                
                if (shift)
                    rx_shiftreg <= {rxd, rx_shiftreg[9:1]};
                    
                if (clear_samplecounter)
                    sample_counter <= 0;
                else if (inc_samplecounter)
                    sample_counter <= sample_counter + 1;
                    
                if (clear_bitcounter)
                    bit_counter <= 0;
                else if (inc_bitcounter)
                    bit_counter <= bit_counter + 1;
            end
        end
    end

    always @(*) begin
        shift = 0;
        clear_samplecounter = 0;
        inc_samplecounter = 0;
        clear_bitcounter = 0;
        inc_bitcounter = 0;
        next_state = state;
        
        case (state)
            0: begin // Idle
                if (!rxd) begin  // Start bit detected
                    next_state = 1;
                    clear_bitcounter = 1;
                    clear_samplecounter = 1;
                end
            end
            
            1: begin // Receiving Data
                if (sample_counter == mid_sample - 1)
                    shift = 1;
                    
                if (sample_counter == div_sample - 1) begin
                    if (bit_counter == div_bit - 1)
                        next_state = 0;
                    inc_bitcounter = 1;
                    clear_samplecounter = 1;
                end else begin
                    inc_samplecounter = 1;
                end
            end
        endcase
    end

    always @(posedge clk_fpga) begin
        if (bit_counter == div_bit-1)
            Rx_data <= rx_shiftreg[8:1];  // Latch received data
    end
endmodule
`timescale 1ns / 1ps

module uart_display (
    input wire clk,      // 50 MHz Clock
    input wire rx,       // UART RX input
    output reg [7:0] led, // LED output (ASCII Verification)
    output reg [6:0] seg, // 7-segment display
    output reg [1:0] an   // 2-digit display enable
);

    wire [7:0] rx_data;
    reg [3:0] tens, ones;
    reg [15:0] refresh_counter = 0;
    reg digit_select = 0; // 0 for ones, 1 for tens

    // Instantiate UART Receiver
    uart_rx uartReceiver (
        .clk_fpga(clk),
        .reset(1'b0),
        .rxd(rx),
        .Rx_data(rx_data)
    );

    // Store received value and extract decimal digits
    always @(posedge clk) begin
        led <= rx_data;   // Display ASCII value in binary on LEDs
        ones <= rx_data % 10;   // Extract ones place
        tens <= rx_data / 10;   // Extract tens place
    end

    // Refresh logic for 7-segment multiplexing (~1ms switching)
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 50000) begin
            digit_select <= ~digit_select;
            refresh_counter <= 0;
        end
    end

    // Assign digit selection (active-low anodes)
    always @(*) begin
        if (digit_select) begin
            an = 2'b10; // Enable Tens place
            seg = seven_seg_decoder(tens);
        end else begin
            an = 2'b01; // Enable Ones place
            seg = seven_seg_decoder(ones);
        end
    end

    // 7-Segment Decoder Function
    function [6:0] seven_seg_decoder;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seven_seg_decoder = 7'b1000000;
                4'd1: seven_seg_decoder = 7'b1111001;
                4'd2: seven_seg_decoder = 7'b0100100;
                4'd3: seven_seg_decoder = 7'b0110000;
                4'd4: seven_seg_decoder = 7'b0011001;
                4'd5: seven_seg_decoder = 7'b0010010;
                4'd6: seven_seg_decoder = 7'b0000010;
                4'd7: seven_seg_decoder = 7'b1111000;
                4'd8: seven_seg_decoder = 7'b0000000;
                4'd9: seven_seg_decoder = 7'b0010000;
                default: seven_seg_decoder = 7'b1111111; // Blank display
            endcase
        end
    endfunction
endmodule
