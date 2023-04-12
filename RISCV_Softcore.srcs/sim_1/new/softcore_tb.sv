`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/10/2023 10:46:32 PM
// Design Name: RISCV Softcore 
// Module Name: softcore_tb
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: Simulation of softcore as a whole
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module softcore_tb();
    
    logic clk = 0;

    // Clock gen
    always #1ns clk = ~clk;
    
    base_regs rf(.clk_i(clk));
    
    initial begin
        #50ns
        
        
        
        $finish();
    end


endmodule
