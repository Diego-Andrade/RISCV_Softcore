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
    import rv32i::word;
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
    input word              raw_instr_i,
    
    // ALU control signals
    output logic            alu_src_op1_o,
    output logic    [1:0]   alu_src_op2_o,
    output alu_func_e       alu_func_o,
    
    // Base Registers
    output logic    [1:0]   base_reg_src_o,
 
    // Decoded Instruction
    output word             instr_o
);

    always_comb begin
        // Defaults
        alu_src_op1_o   = ALU_SRC_RS1;
        alu_src_op2_o   = ALU_SRC_RS2;
        alu_func_o      = _NONE;
        base_reg_src_o  = BASE_REG_SRC_ALU_RESULT;
        
        // Handle instruction types
        unique case (raw_instr_i[6:0])
            LUI: begin
                instr.utype_s.imm20     = raw_instr_i[31:12];
                instr.utype_s.rd_addr   = raw_instr_i[11:7];
                instr.utype_s.opcode    = LUI;
            
                alu_src_op1_o   = ALU_SRC_U_IMMED;
                alu_func_o      = _COPY;
            end

            AUIPC: begin
                instr.utype_s.imm20     = raw_instr_i[31:12];
                instr.utype_s.rd_addr   = raw_instr_i[11:7];
                instr.utype_s.opcode    = AUIPC;
            
                alu_src_op1_o   = ALU_SRC_U_IMMED;
                alu_src_op2_o   = ALU_SRC_PC;
                alu_func_o      = _ADD;
            end

            JAL: begin
                instr.jtype_s.imm20     = {raw_instr_i[19:12], raw_instr_i[20], raw_instr_i[30:21], 1'b0};
                instr.jtype_s.rd_addr   = raw_instr_i[11:7];
                instr.jtype_s.opcode    = JAL;

                alu_src_op1_o   = ALU_SRC_U_IMMED;
                alu_src_op2_o   = ALU_SRC_PC;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_PC_4;
            end

            JALR: begin
                instr.itype_s.imm12     = raw_instr_i[31:20];
                instr.itype_s.rs1_addr  = raw_instr_i[19:15];
                instr.itype_s.func3     = raw_instr_i[14:12];
                instr.itype_s.rd_addr   = raw_instr_i[11:7];
                instr.itype_s.opcode    = JALR;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_PC_4;
            end

            BRANCH: begin
                instr.btype_s.imm12     = {raw_instr_i[7], raw_instr_i[30:25], raw_instr_i[11:8], 1'b0};
                instr.btype_s.rs2_addr  = raw_instr_i[24:20];
                instr.btype_s.rs1_addr  = raw_instr_i[19:15];
                instr.btype_s.func3     = raw_instr_i[14:12];
                instr.btype_s.opcode    = BRANCH;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;
                unique case (instr.btype_s.func3)
                    _EQ: alu_func_o = _BEQ;
                    _NE: alu_func_o = _BEQ;
                    _LT: alu_func_o = _BLT;
                    _GE: alu_func_o = _BLT;
                    _LTU: alu_func_o = _BLTU;
                    _GEU: alu_func_o = _BLTU;
                endcase
            end

            LOAD: begin
                instr.itype_s.imm12     = raw_instr_i[31:20];
                instr.itype_s.rs1_addr  = raw_instr_i[19:15];
                instr.itype_s.func3     = raw_instr_i[14:12];
                instr.itype_s.rd_addr   = raw_instr_i[11:7];
                instr.itype_s.opcode    = LOAD;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_MEM;
            end

            STORE: begin
                instr.stype_s.imm12     = {raw_instr_i[31:25], raw_instr_i[11:7]};
                instr.stype_s.rs2_addr  = raw_instr_i[24:20];
                instr.stype_s.rs1_addr  = raw_instr_i[19:15];
                instr.stype_s.func3     = raw_instr_i[14:12];
                instr.stype_s.opcode    = STORE;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_S_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end

            OP_IMM: begin
                instr.itype_s.imm12     = raw_instr_i[31:20];
                instr.itype_s.rs1_addr  = raw_instr_i[19:15];
                instr.itype_s.func3     = raw_instr_i[14:12];
                instr.itype_s.rd_addr   = raw_instr_i[11:7];
                instr.itype_s.opcode    = OP_IMM;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_I_IMMED;

                // Handle special I-Type cases: shift right (SR**) and shift left (SL**)
                if (instr.itype_s.func3 == 3'b001 || instr.itype_s.func3 == 3'b101)
                    alu_func_o  = alu_func_e'({instr.itype_s.imm12[10], instr.itype_s.func3});
                else
                    alu_func_o  = alu_func_e'({1'b0, instr.itype_s.func3});
                    
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end

            OP: begin
                instr.rtype_s.func7     = raw_instr_i[31:25];
                instr.rtype_s.rs2_addr  = raw_instr_i[24:20];
                instr.rtype_s.rs1_addr  = raw_instr_i[19:15];
                instr.rtype_s.func3     = raw_instr_i[14:12];
                instr.rtype_s.rd_addr   = raw_instr_i[11:7];
                instr.rtype_s.opcode    = OP;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_RS2;
                alu_func_o      = alu_func_e'({1'b0, instr.itype_s.func3});    
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end
        endcase
    end // Comb end


endmodule
