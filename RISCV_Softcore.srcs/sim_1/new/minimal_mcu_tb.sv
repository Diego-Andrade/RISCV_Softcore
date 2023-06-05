`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 06/03/2023 11:22:25 PM
// Design Name: RISCV Softcore 
// Module Name: minimal_mcu_tb
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: Simulation of MCU as a whole
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module minimal_mcu_tb();
    
    logic clk = 0;

    // Clock gen
    always #1ns clk = ~clk;
    
    logic reset = 0;
    logic [15:0] leds = 0;
    logic [15:0] switches = 0;
    
    minimal_mcu mcu(
        .CLK(clk),
        .RESET(reset),
        .LEDS(leds), .SWITCHES(switches));
    
    initial begin
        reset = 1;
        #3ns;
        reset = 0;
        #50ns;
        
        
        
        $finish();
    end


endmodule
