//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/11/2023 12:37:04 PM
// Design Name: RISCV Softcore
// Module Name: softcore
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: Top module wrapping softcore processor, memory, and peripherals
// 
// Dependencies: riscv_isa
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module softcore
    import rv32i::word;
(
    input logic clk_i,
    input logic reset_i
    
    
);
    
    prog_counter pc();
    alu alu();
    cu_fsm cu_fsm();
    cu_decoder cu_decoder();
    base_regs base_regs();
    
    // Mapping func3 to CSR functions
    /*
    csr_func_e csr_func_i;
    always_comb begin
        csr_func_i = csr_func_e'(func3_i);
    end
    */
    
    
endmodule
