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
    
    import rv32i::word;
    
    logic clk = 0;
    logic reset = 1;
    
    word prog_count;
 

    // Clock gen
    always #1ns clk = ~clk;
    
    prog_counter pc(
        .clk_i(clk), .reset_i(reset),
        .w_en_i(1'b1), .w_data_i(prog_count+4),
        .prog_count_o(prog_count));
    
    initial begin
        #2ns;
        reset = 0;
        #50ns
        
        
        
        $finish();
    end


endmodule
