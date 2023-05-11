////////////////////////////////////////////////////////////////////////////////// 
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/20/2023 01:43:55 PM
// Design Name: RISCV Softcore
// Module Name: cu_decoder
// Project Name: RISCV_SOFTCORE
// Target Devices: Xilinx Artix-7
// Description: The control unit instruction decoder
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cu_decoder
    import rv32i_opcode::*;
    import rv32i::instruction_u;
    import rv32i_functions::*;
#(
    // ALU src op1
    parameter ALU_SRC_RS1               = 1'b0,
    parameter ALU_SRC_U_IMMED           = 1'b1,
    
    // ALU src op2
    parameter ALU_SRC_RS2               = 2'd0,
    parameter ALU_SRC_I_IMMED           = 2'd1,
    parameter ALU_SRC_S_IMMED           = 2'd2,
    parameter ALU_SRC_PC                = 2'd3,
    
    // Base Registers src
    parameter BASE_REG_SRC_ALU_RESULT   = 2'd0,
    parameter BASE_REG_SRC_MEM          = 2'd1,
    parameter BASE_REG_SRC_CSR          = 2'd2,
    parameter BASE_REG_SRC_PC_4         = 2'd3,
    
    // Prog Counter
    parameter PC_SRC_PC_4               = 2'd0,
    parameter PC_SRC_JALR               = 2'd1,
    parameter PC_SRC_BRANCH             = 2'd2,
    parameter PC_SRC_JAL                = 2'd3
)
(
    // Instruction data
    input opcode_e          opcode_i,
    input logic     [2:0]   func3_i,
    input logic     [6:0]   func7_i,
    
    // Branch
    input logic             br_eq_i,
    input logic             br_lt_i,
    input logic             br_ltu_i,
    
    // ALU control signals
    output logic            alu_src_op1_o,
    output logic    [1:0]   alu_src_op2_o,
    output alu_func_e       alu_func_o,
    
    // Base Registers
    output logic    [1:0]   base_reg_src_o,
    
    // Program Counter control signals
    output logic    [3:0]   pc_src_o
);

    always_comb begin
        // Defaults
        alu_src_op1_o   = ALU_SRC_RS1;
        alu_src_op2_o   = ALU_SRC_RS2;
        alu_func_o      = _NONE;
        base_reg_src_o  = BASE_REG_SRC_ALU_RESULT;
        pc_src_o        = PC_SRC_PC_4;
        
        // Handle instruction types
        unique case (opcode_i)
            LUI: begin
                alu_src_op1_o   = ALU_SRC_U_IMMED;
                alu_func_o      = _COPY;
            end

            AUIPC: begin
                alu_src_op1_o   = ALU_SRC_U_IMMED;
                alu_src_op2_o   = ALU_SRC_PC;
                alu_func_o      = _ADD;
            end

            JAL: begin
                alu_src_op1_o   = ALU_SRC_U_IMMED;
                alu_src_op2_o   = ALU_SRC_PC;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_PC_4;
                pc_src_o        = PC_SRC_JAL;
            end
 
            JALR: begin
                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_PC_4;
                pc_src_o        = PC_SRC_JALR;
            end

            BRANCH: begin
                pc_src_o        = PC_SRC_BRANCH;
            end

            LOAD: begin
                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_MEM;
            end

            STORE: begin
                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_S_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end

            OP_IMM: begin
                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;

                // Handle special cases shift right (SR**) and shift left (SL**)
                if (func3_i == 3'b001 || func3_i == 3'b101)
                    alu_func_o  = alu_func_e'({1'b0, func3_i});
                else
                    alu_func_o  = alu_func_e'({func7_i[5], func3_i});
                    
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end

            OP: begin
                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;
                alu_func_o  = alu_func_e'({func7_i[5], func3_i});    
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end
        endcase
    end // Comb end


endmodule
