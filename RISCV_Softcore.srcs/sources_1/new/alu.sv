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
    input alu_func_e            alu_func_i,
    input logic         [31:0]  op1_i, 
    input logic         [31:0]  op2_i,
    
    output logic        [31:0]  result_o
);
 
    always_comb begin
        case (alu_func_i)
            _ADD:   result_o = op1_i + op2_i;
            _SUB:   result_o = op1_i - op2_i;
            _OR:    result_o = op1_i | op2_i;
            _AND:   result_o = op1_i & op2_i;
            _XOR:   result_o = op1_i ^ op2_i;
            _SRL:   result_o = op1_i >> op2_i[4:0];
            _SLL:   result_o = op1_i << op2_i[4:0];
            _SRA:   result_o =  $signed(op1_i) >>> op2_i[4:0];
            _SLT:   result_o = $signed(op1_i) < $signed(op2_i) ? 1: 0;
            _SLTU:  result_o = op1_i < op2_i ? 1: 0;
            _LUI:   result_o = op1_i; //copy
        endcase
    end

endmodule