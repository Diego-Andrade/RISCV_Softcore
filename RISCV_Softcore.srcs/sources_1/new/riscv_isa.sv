//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/09/2023 01:22:23 AM
// Design Name: RISCV Softcore
// Module Name: None
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: A package namespace to hold ISA constants and formats
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package rv32i_opcode;

    // Opcodes for 32-bit instructions   
    // Note: First two bits are always 11 for rv32i
    typedef enum logic [6:0] {
        LUI      = 7'b0110111,          
        AUIPC    = 7'b0010111,

        JAL      = 7'b1101111, 
        JALR     = 7'b1100111,
        BRANCH   = 7'b1100011,

        LOAD     = 7'b0000011,
        STORE    = 7'b0100011,
        OP_IMM   = 7'b0010011,
        OP       = 7'b0110011,

        SYSTEM   = 7'b1110011
    } opcode_e;

endpackage

package rv32i_functions;

    // ALU functions
    // Note: Most match instruction { func7[5], func3 } bits,
    //       exceptions:
    //       _COPY, _BEQ, _BLT, _BLTU, _NONE
    typedef enum logic [3:0] { 
        _ADD    = {1'b0, 3'b000},
        _SUB    = {1'b1, 3'b000}, 
        _SLL    = {1'b0, 3'b001}, 
        _SLT    = {1'b0, 3'b010}, 
        _SLTU   = {1'b0, 3'b011},
        _XOR    = {1'b0, 3'b100},
        _SRL    = {1'b0, 3'b101},
        _SRA    = {1'b1, 3'b101},
        _OR     = {1'b0, 3'b110},
        _AND    = {1'b0, 3'b111},
        _COPY   = {1'b1, 3'b001},
        _BEQ    = {1'b1, 3'b010},
        _BLT    = {1'b1, 3'b011},
        _BLTU   = {1'b1, 3'b100},
        _NONE   = {1'b1, 3'b111}
    } alu_func_e;

    // Memory accessing size
    typedef enum logic [2:0] {
        _B      = 3'b000,
        _BU     = 3'b100,
        _HW     = 3'b001,
        _HWU    = 3'b101,
        _W      = 3'b010
    } size_func_e;
    
    // CSR funcions, composed of func3
    typedef enum logic [2:0] {
        _RW     = 3'b001,
        _RWI    = 3'b101,
        _RS     = 3'b010,
        _RSI    = 3'b110,
        _RC     = 3'b011,
        _RCI    = 3'b111
    } csr_func_e;

    typedef enum logic [2:0] {
        _EQ     = 3'b000,
        _NE     = 3'b001,
        _LT     = 3'b100,
        _GE     = 3'b101,
        _LTU    = 3'b110,
        _GEU    = 3'b111
    } branch_func_e;

endpackage

package rv32i;
    import rv32i_opcode::*;

    // Data definitions
    typedef logic [31:0]    word;
    typedef logic [15:0]    half_word;

    // Instruction type encoding
    typedef union packed {
        word data;

        struct packed {
            logic [6:0]     func7;
            logic [4:0]     rs2_addr;
            logic [4:0]     rs1_addr;
            logic [2:0]     func3;
            logic [4:0]     rd_addr;
            opcode_e        opcode;
        } rtype_s;

        struct packed {
            logic [11:0]    raw_immed;          // immed [11:0]
            logic [4:0]     rs1_addr;
            logic [2:0]     func3;
            logic [4:0]     rd_addr;
            opcode_e        opcode;
        } itype_s;

        struct packed {
            logic [6:0]     raw_immed_2;        // immed [11:5]
            logic [4:0]     rs2_addr;
            logic [4:0]     rs1_addr;
            logic [2:0]     func3;
            logic [4:0]     raw_immed_1;        // immed [4:0]
            opcode_e        opcode;
        } stype_s;

         struct packed {
            logic [6:0]    raw_immed_2;        // immed [12][10:5]
            logic [4:0]     rs2_addr;
            logic [4:0]     rs1_addr;
            logic [2:0]     func3;
            logic [4:0]     raw_immed_1;        // immed [4:1][11]
            opcode_e        opcode;
        } btype_s;

        struct packed {
            logic [19:0]    raw_immed;          // immed [11:0]
            logic [4:0]     rd_addr;
            opcode_e        opcode;
        } utype_s;

        struct packed {
            logic [19:0]    raw_immed;          // immed[20][10:1][11][19:12]
            logic [4:0]     rd_addr;
            opcode_e        opcode;
        } jtype_s;       

    } instruction_u;

endpackage

