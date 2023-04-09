`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 03/24/2023 01:30:39 AM
// Design Name: RISCV_Softcore
// Module Name: ALU
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: 
// 
// Dependencies: RISCV_ISA
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input logic [3:0] Operation,
    input logic [31:0] A, B,
    
    output logic [31:0] Result
    );
    
    enum { _ADD = 0, _SLL = 1, _SLT = 2, _SLTU = 3, _XOR = 4, _SRL = 5, 
           _OR = 6,  _AND = 7, _SUB = 8,  _LUI = 9, _MULT = 10, _SRA = 13
         } Operations;
         
         
    case (Operation) 
        _ADD: Result = A + B;
        
        default: Result = 0;
    endcase
    
    
endmodule
