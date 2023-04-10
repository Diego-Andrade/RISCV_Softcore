`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/09/2023 01:21:44 AM
// Design Name: RISCV Softcore
// Module Name: alu
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: 
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu
    import rv32i_functions::*;
(
    input alu_func_e func,
    input logic [31:0] a, b,
    
    output logic [31:0] result
);
 
    always_comb begin
        case (func)
            _ADD :  result = a + b;
            _SUB:   result = a - b;
            _OR:    result = a | b;
            _AND:   result = a & b;
            _XOR:   result = a ^ b;
            _SRL:   result =  a >> b[4:0];
            _SLL:   result =  a << b[4:0];
            _SRA:    result =  $signed(a) >>> b[4:0];
            _SLT:  result = $signed(a) < $signed(b) ? 1: 0;
            _SLTU:  result = a < b ? 1: 0;
            _LUI:  result = a; //copy

            default: result = 0;
        endcase
    end

endmodule