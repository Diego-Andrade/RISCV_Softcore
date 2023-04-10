`timescale 1ns / 1ps
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


package rv32i;
    
    // Instruction type encoding
    typedef union packed {
        logic [31:0] data;
    
        struct packed {
            logic [6:0] funct7;
            logic [4:0] rs2;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [4:0] rd;
            logic [6:0] opcode;
        } rtype_s;
        
        struct packed {
            logic [11:0] imm_11to0;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [4:0] rd;
            logic [6:0] opcode;
        } itype_s;
        
        struct packed {
            logic [6:0] imm_11to5;
            logic [4:0] rs2;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [4:0] imm_4to0;
            logic [6:0] opcode;
        } stype_s;
        
         struct packed {
            logic [6:0] imm_12_10to5;
            logic [4:0] rs2;
            logic [4:0] rs1;
            logic [2:0] funct3;
            logic [4:0] imm_4to1_11;
            logic [6:0] opcode;
        } btype_s;

        struct packed {
            logic [19:0] imm_31to12;
            logic [4:0] rd;
            logic [6:0] opcode;
        } ustype_s;
     
        struct packed {
            logic [19:0] imm_20_10to1_11_19to12;
            logic [4:0] rd;
            logic [6:0] opcode;
        } jtype_s;       
        
    } instruction_u;

endpackage

package rv32i_functions;

    // ALU functions, composed of { func7[5], func3 }
    typedef enum logic [3:0] { 
        _ADD = 0, _SLL = 1, _SLT = 2, _SLTU = 3, _XOR = 4, _SRL = 5, 
        _OR = 6,  _AND = 7, _SUB = 8,  _LUI = 9, _SRA = 13
    } alu_func_e;



endpackage