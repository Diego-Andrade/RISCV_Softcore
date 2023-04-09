`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/09/2023 01:21:44 AM
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


module alu
    import riscv_isa::opcode_e;
(
    input opcode_e opcode,
    input logic [31:0] A, B,
    
    output logic [31:0] Result
);
   
       
    always_comb begin  
        case (opcode) 
            riscv_isa::ADD : Result = A + B;
            
            default: Result = 0;
        endcase
    end
    
    
endmodule