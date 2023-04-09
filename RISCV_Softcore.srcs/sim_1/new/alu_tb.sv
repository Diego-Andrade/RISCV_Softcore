`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2023 01:19:29 AM
// Design Name: 
// Module Name: alu_tb
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


module alu_tb ();
    import riscv_isa::*;

    opcode_e opcode;
    logic [31:0] A, B, Result;

    alu alu(.*);

    initial begin
        A = 0; B = 0; opcode = ADD;
        #1
        A = 2; B = 5;
        #1
        opcode = SUB;
        #1
        A = 3; B = 6;
        #1
        opcode = ADD;
        #1
        $finish;
    end
    
endmodule
