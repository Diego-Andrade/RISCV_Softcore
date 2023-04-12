`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2023 12:37:04 PM
// Design Name: 
// Module Name: softcore
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module softcore(
    input logic clk_i,
    input logic reset_i
    
    
);
    
    alu alu();
    cu_fsm cu_fsm();
    base_regs base_regs();
    
    // Mapping func3 to CSR functions
    /*
    csr_func_e csr_func_i;
    always_comb begin
        csr_func_i = csr_func_e'(func3_i);
    end
    */
    
    
endmodule
