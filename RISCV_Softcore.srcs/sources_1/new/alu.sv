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
    import rv32i::word;
    import rv32i_functions::*;
(
    input alu_func_e    alu_func_i,     // ALU function to perform
    input word          op1_i,          // Operand 1
    input word          op2_i,          // Operand 2

    output word         result_o        // Result of operation
);
 
    always_comb begin
        unique case (alu_func_i)
            _ADD:   result_o = op1_i + op2_i;
            _SUB:   result_o = op1_i - op2_i;
            _OR:    result_o = op1_i | op2_i;
            _AND:   result_o = op1_i & op2_i;
            _XOR:   result_o = op1_i ^ op2_i;
            _SRL:   result_o = op1_i >> op2_i[4:0];
            _SLL:   result_o = op1_i << op2_i[4:0];
            _SRA:   result_o = $signed(op1_i) >>> op2_i[4:0];
            _SLT:   result_o = $signed(op1_i) < $signed(op2_i) ? 1: 0;
            _SLTU:  result_o = op1_i < op2_i ? 1: 0;
            _COPY:  result_o = op1_i;
            _BEQ:   result_o = op1_i == op2_i;
            _BLT:   result_o = $signed(op1_i) < $signed(op2_i);
            _BLTU:  result_o = op1_i < op2_i;
            _NONE:  result_o = 0;
        endcase
    end


endmodule
