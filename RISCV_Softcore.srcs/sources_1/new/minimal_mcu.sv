////////////////////////////////////////////////////////////////////////////////// 
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 06/03/2023 09:46:34 PM
// Design Name: RISCV Softcore
// Module Name: minimal_mcu
// Project Name: RISCV_SOFTCORE
// Target Devices: Xilinx Artix-7
// Description: Top level module wrapping RISCV softcore and external peripherals
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module minimal_mcu
    import rv32i::word;
(
    // Control signals
    input CLK,
    input RESET,
    
    // IO
    input   logic [15:0] SWITCHES,
    output  logic [15:0] LEDS
);


    // ---- IO mapping --------------------------
    parameter IO_BASE           = 32'h10000000;
    parameter IO_LEDS_ADDR      = IO_BASE + 0;
    parameter IO_SWITCHES_ADDR  = IO_BASE + 4;

    word    io_data_in;
    word    io_data_out;
    word    io_addr;
//    word    io_r_en;
    word    io_w_en;
    
    // Inputs - async
    always_comb begin
        case (io_addr)
            IO_LEDS_ADDR:       io_data_in = LEDS;
            IO_SWITCHES_ADDR:   io_data_in = SWITCHES;
            
            default:            io_data_in = 32'hz;
        endcase
    end

    // Outputs
    always_ff @ (posedge CLK) begin
        if (RESET) begin
            LEDS <= '0;
        end
        else if (io_w_en) begin
            case (io_addr)
                IO_LEDS_ADDR:   LEDS <= io_data_out;               
            endcase
        end
    end


    // ---- CPU with internal Memory ------------

    softcore #(.IO_SPACE(32'h10000000)) cpu (
        .clk_i(CLK), .reset_i(RESET),
        .io_addr_o(io_addr), .io_data_i(io_data_in), 
        .io_w_en_o(io_w_en), .io_data_o(io_data_out));

endmodule