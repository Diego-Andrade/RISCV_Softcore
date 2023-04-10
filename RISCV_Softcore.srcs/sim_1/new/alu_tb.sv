`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com
// 
// Create Date: 04/09/2023 01:19:29 AM
// Design Name: RISCV Softcore
// Module Name: alu_tb
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: Testbench for ALU
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb ();
    import rv32i_functions::*;

    alu_func_e func;
    logic [31:0] A, B, Result;

    alu alu(.op1_i(A), .op2_i(B), .alu_func_i(func), .result_o(Result));

    initial begin
        A = 0; B = 0; func = _ADD; #1
        assert(Result == 0) else $display ("Add failed"); #1
        
        A = 77; B = 222; func = _ADD; #1
        assert(Result == 299) else $display ("Add failed"); #1
        
        A = 24; B = -224; func = _ADD; #1
        assert(Result == -200) else $display ("Add negative failed"); #1
        
        A = 123; B = 223; func = _SUB; #1
        assert(Result == 100) else $display ("Sub failed"); #1
        
        $finish;
    end
    
endmodule
