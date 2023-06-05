//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/11/2023 10:52:24 PM
// Design Name: RISCV Softcore
// Module Name: prog_counter
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: The program instruction counter register
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module prog_counter
    import rv32i::word;
(
    // Control Signals
    input   logic   clk_i,          // Clock
    input   logic   reset_i,        // Reset
    
    // Writes
    input   logic   w_en_i,         // Write enable
    input   word    w_data_i,       // Write data
 
    // Status
    output  word    prog_count_o    // Program count
);

//    // Setup
//    initial begin
//        prog_count_o = 0;
//    end

    // Sync update
    always_ff @ (posedge clk_i) begin
        if (reset_i) begin
            prog_count_o <= 0;
        end
        else if (w_en_i) begin
            prog_count_o <= w_data_i;
        end
    end


endmodule
