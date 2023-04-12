`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/11/2023 12:39:31 PM
// Design Name: RISCV Softcore
// Module Name: base_regs
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: The base integer registers implementation
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module base_regs
    import rv32i::word;
    import rv32i::register;
(
    // Control signals
    input logic clk_i,              // Clock
    input logic rest_i,             // Resest    

    // Async read
    input register  r_addr1_i,      // Async read address 1
    input register  r_addr2_i,      //  2
    output word     r_data1_o,      // Async read data 1
    output word     r_data2_o,      //  2
        
    // Sync write
    input           w_en_i,         // Sync write enable
    input word      w_addr_i,       // Sync write address
    input word      w_data_i        // Sync write data
);

    // Register array
    word registers [0:31] = '{default:0};

    // Async reads
    assign r_data1_o = registers[r_addr1_i];
    assign r_data2_o = registers[r_addr2_i];

    // Sync writes
    always_ff @ (posedge clk_i) begin
    if (w_en_i && w_addr_i != 0)
       registers[w_addr_i] <= w_data_i;
    end


endmodule
