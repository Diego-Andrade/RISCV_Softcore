//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 05/11/2023 11:26:04 PM
// Design Name: RISCV Softcore
// Module Name: ram_dualport
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Atrix-7
// Description: Byte addressable dual port ram
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      Currently not supporting missaligned access, but framework left for support
//      in the future
//
//////////////////////////////////////////////////////////////////////////////////

module ram_dualport 
    import rv32i::word;
    import rv32i_functions::*;
#(
    parameter ADDRESS_SIZE = 14
)
(
    // Control signals
    input   logic       clk_i,
    input   logic       reset_i,

    // Port 1
    input   logic       r_en1_i,
    input   word        addr1_i,
    output  word        r_data1_o,
    
    // Port 2
    input   logic       r_en2_i,
    input   word        addr2_i,
    input   size_func_e size2_i,        // Whether accesing byte, halfword, or word
    output  word        r_data2_o,
    
    input   logic       w_en2_i,
    input   word        w_data2_i
);

    // RAM definition
    (* rom_style="{distributed | block}" *) 
    (* ram_decomp = "power" *) 
    word memory [0:(2**ADDRESS_SIZE)-1];

    // Mapping byte addressable to word addressable
    // Port 1
    logic [ADDRESS_SIZE-1: 0]   word_addr1;
    assign word_addr1 = addr1_i[(ADDRESS_SIZE-1)+2:2];

    // Port 2
    logic [ADDRESS_SIZE-1: 0]   word_addr2;
    logic [1:0]                 byte_addr2;
    assign word_addr2 = addr2_i[(ADDRESS_SIZE-1)+2:2];
    assign byte_addr2 = addr2_i[1:0];

    // Address validation
    logic valid_addr1;
    assign valid_addr1 = word_addr1 < (2**ADDRESS_SIZE);

    logic valid_addr2;
    assign valid_addr2 = word_addr1 < (2**ADDRESS_SIZE) && (
                         (size2_i == _B || size2_i == _BU) ||
                         ((size2_i == _HW || size2_i == _HWU) && byte_addr2[0] == 1'b0) ||      // Halfword aligned
                         (size2_i == _W && byte_addr2 == 2'b0));                                // Word aligned

    // Synced memory reads and writes
    always_ff @ (posedge clk_i) begin
        if (reset_i) begin
            memory <= '{default: 0};
        end
        else begin
            // Defaults
            r_data1_o <= '0;
            r_data2_o <= '0;

            // Port 1
            if (r_en1_i && valid_addr1) begin
                r_data1_o <= memory[word_addr1];
            end

            // Port 2
            // Reading
            if (r_en2_i && valid_addr2) begin
                case (size2_i)
                    _B: unique case (byte_addr2)
                        0: r_data2_o <= {{24{memory[word_addr2][7]}},  memory[word_addr2][7:0]};           
                        1: r_data2_o <= {{24{memory[word_addr2][15]}}, memory[word_addr2][15:8]};
                        2: r_data2_o <= {{24{memory[word_addr2][23]}}, memory[word_addr2][23:16]};
                        3: r_data2_o <= {{24{memory[word_addr2][31]}}, memory[word_addr2][31:24]};
                    endcase   

                    _BU: unique case (byte_addr2)
                        0: r_data2_o <= {{24{1'b0}},  memory[word_addr2][7:0]};           
                        1: r_data2_o <= {{24{1'b0}}, memory[word_addr2][15:8]};
                        2: r_data2_o <= {{24{1'b0}}, memory[word_addr2][23:16]};
                        3: r_data2_o <= {{24{1'b0}}, memory[word_addr2][31:24]};
                    endcase

                    _HW: unique case (byte_addr2[1])
                        0: r_data2_o <= {{16{memory[word_addr2][15]}}, memory[word_addr2][15:0]};           
                        1: r_data2_o <= {{16{memory[word_addr2][31]}}, memory[word_addr2][31:16]};
                    endcase

                    _HWU: unique case (byte_addr2[1])
                        0: r_data2_o <= {{24{1'b0}}, memory[word_addr2][15:0]};           
                        1: r_data2_o <= {{24{1'b0}}, memory[word_addr2][31:16]};
                    endcase

                    default: r_data2_o <= memory[word_addr2];   // Note: Reading word on incorrect func3
                endcase
            end

            // Writing
            if (w_en2_i && valid_addr2) begin
                case (size2_i)
                    _B: unique case (byte_addr2)
                        0: memory[word_addr2][7:0]   <= w_data2_i[7:0];           
                        1: memory[word_addr2][15:8]  <= w_data2_i[15:8];
                        2: memory[word_addr2][23:16] <= w_data2_i[23:16];
                        3: memory[word_addr2][31:24] <= w_data2_i[31:24];
                    endcase   

                    _HW: unique case (byte_addr2[1])
                        0: memory[word_addr2][15:0]  <= w_data2_i[15:0];           
                        1: memory[word_addr2][31:16] <= w_data2_i[15:0];
                    endcase

                    default: memory[word_addr2] <= w_data2_i;

                endcase
            end
        end
    end

endmodule

