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
    import rv32i::*;
    import rv32i_opcode::*;
    import rv32i_functions::*;
#(
    // ALU op1 sources
    parameter ALU_SRC_RS1               = 1'b0,
    parameter ALU_SRC_IMMED             = 1'b1,
    
    // ALU op2 sources
    parameter ALU_SRC_RS2               = 2'd0,
//    parameter ALU_SRC_IMMED             = 2'd1,   // Reusing above definition
    parameter ALU_SRC_PC                = 2'd2,
    
    // Base Registers sources
    parameter BASE_REG_SRC_ALU_RESULT   = 2'd0,
    parameter BASE_REG_SRC_MEM          = 2'd1,
    parameter BASE_REG_SRC_CSR          = 2'd2,
    parameter BASE_REG_SRC_PC_4         = 2'd3,
    
    // Program counter sources
    parameter PC_SRC_PC_4               = 2'd0,
    parameter PC_SRC_JALR               = 2'd1,
    parameter PC_SRC_BRANCH             = 2'd2,
    parameter PC_SRC_JAL                = 2'd3
)
(
    // Raw instruction data
    input   word            raw_instr_i,
    
    // ALU control signals
    output  logic           alu_src_op1_o,
    output  logic [1:0]     alu_src_op2_o,
    output  alu_func_e      alu_func_o,
    
    // Base Register control signal
    output  logic    [1:0]  base_reg_src_o,
 
    // Decoded instruction data
    output  instruction_u   instr_o,
    output  word            immed_o
);

    // Mapping raw instruction to type
    assign instr_o.data = raw_instr_i;

    // Set appropriate control signals
    always_comb begin
        // Defaults
        alu_src_op1_o   = ALU_SRC_RS1;
        alu_src_op2_o   = ALU_SRC_RS2;
        alu_func_o      = _NONE;
        base_reg_src_o  = BASE_REG_SRC_ALU_RESULT;
        immed_o         = 0;
        
        // Handle instruction types
        unique case (raw_instr_i[6:0])
            LUI: begin
//                instr.utype_s.imm20     = raw_instr_i[31:12];
//                instr.utype_s.rd_addr   = raw_instr_i[11:7];
//                instr.utype_s.opcode    = LUI;
            
                alu_src_op1_o   = ALU_SRC_IMMED;
                alu_func_o      = _COPY;
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT;
                immed_o         = {instr_o.utype_s.raw_immed, {12{1'b0}}};
            end

            AUIPC: begin
//                instr.utype_s.imm20     = raw_instr_i[31:12];
//                instr.utype_s.rd_addr   = raw_instr_i[11:7];
//                instr.utype_s.opcode    = AUIPC;
            
                alu_src_op1_o   = ALU_SRC_IMMED;
                alu_src_op2_o   = ALU_SRC_PC;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT;
                immed_o         = {instr_o.utype_s.raw_immed, {12{1'b0}}};
            end

            JAL: begin
//                instr.jtype_s.imm20     = {raw_instr_i[19:12], raw_instr_i[20], raw_instr_i[30:21], 1'b0};
//                instr.jtype_s.rd_addr   = raw_instr_i[11:7];
//                instr.jtype_s.opcode    = JAL;

                base_reg_src_o  = BASE_REG_SRC_PC_4;
                immed_o         = {
                    {12{instr_o.jtype_s.raw_immed[19]}}, 
                    instr_o.jtype_s.raw_immed[7:0], 
                    instr_o.jtype_s.raw_immed[8], 
                    instr_o.jtype_s.raw_immed[18:9], 
                    1'b0};  // byte aligned
            end

            JALR: begin
//                instr.itype_s.imm12     = raw_instr_i[31:20];
//                instr.itype_s.rs1_addr  = raw_instr_i[19:15];
//                instr.itype_s.func3     = raw_instr_i[14:12];
//                instr.itype_s.rd_addr   = raw_instr_i[11:7];
//                instr.itype_s.opcode    = JALR;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_PC_4;
                immed_o         = instr_o.itype_s.raw_immed;
            end

            BRANCH: begin
//                instr.btype_s.imm12     = {raw_instr_i[7], raw_instr_i[30:25], raw_instr_i[11:8], 1'b0};
//                instr.btype_s.rs2_addr  = raw_instr_i[24:20];
//                instr.btype_s.rs1_addr  = raw_instr_i[19:15];
//                instr.btype_s.func3     = raw_instr_i[14:12];
//                instr.btype_s.opcode    = BRANCH;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_RS2;
                unique case (instr_o.btype_s.func3)
                    _EQ: alu_func_o = _BEQ;
                    _NE: alu_func_o = _BEQ;
                    _LT: alu_func_o = _BLT;
                    _GE: alu_func_o = _BLT;
                    _LTU: alu_func_o = _BLTU;
                    _GEU: alu_func_o = _BLTU;
                endcase
                immed_o = {
                    {20{instr_o.btype_s.raw_immed_2[6]}}, 
                    instr_o.btype_s.raw_immed_1[0], 
                    instr_o.btype_s.raw_immed_2[5:0], 
                    instr_o.btype_s.raw_immed_1[4:1],
                    1'b0};  // byte aligned
            end

            LOAD: begin
//                instr.itype_s.imm12     = raw_instr_i[31:20];
//                instr.itype_s.rs1_addr  = raw_instr_i[19:15];
//                instr.itype_s.func3     = raw_instr_i[14:12];
//                instr.itype_s.rd_addr   = raw_instr_i[11:7];
//                instr.itype_s.opcode    = LOAD;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_IMMED;
                alu_func_o      = _ADD;
                base_reg_src_o  = BASE_REG_SRC_MEM;
                immed_o         = instr_o.itype_s.raw_immed;
            end

            STORE: begin
//                instr.stype_s.imm12     = {raw_instr_i[31:25], raw_instr_i[11:7]};
//                instr.stype_s.rs2_addr  = raw_instr_i[24:20];
//                instr.stype_s.rs1_addr  = raw_instr_i[19:15];
//                instr.stype_s.func3     = raw_instr_i[14:12];
//                instr.stype_s.opcode    = STORE;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_IMMED;
                alu_func_o      = _ADD;
                immed_o         = {
                    {20{instr_o.stype_s.raw_immed_2[6]}},
                    instr_o.stype_s.raw_immed_2[6:0],
                    instr_o.stype_s.raw_immed_1[4:0]};
            end

            OP_IMM: begin
//                instr.itype_s.imm12     = raw_instr_i[31:20];
//                instr.itype_s.rs1_addr  = raw_instr_i[19:15];
//                instr.itype_s.func3     = raw_instr_i[14:12];
//                instr.itype_s.rd_addr   = raw_instr_i[11:7];
//                instr.itype_s.opcode    = OP_IMM;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_IMMED;

                // Handle special I-Type cases: shift right (SR**) and shift left (SL**)
                if (instr_o.itype_s.func3 == 3'b001 || instr_o.itype_s.func3 == 3'b101)
                    alu_func_o  = alu_func_e'({instr_o.itype_s.raw_immed[10], instr_o.itype_s.func3});
                else
                    alu_func_o  = alu_func_e'({1'b0, instr_o.itype_s.func3});
                    
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT;
                immed_o         = instr_o.itype_s.raw_immed;
            end

            OP: begin
//                instr.rtype_s.func7     = raw_instr_i[31:25];
//                instr.rtype_s.rs2_addr  = raw_instr_i[24:20];
//                instr.rtype_s.rs1_addr  = raw_instr_i[19:15];
//                instr.rtype_s.func3     = raw_instr_i[14:12];
//                instr.rtype_s.rd_addr   = raw_instr_i[11:7];
//                instr.rtype_s.opcode    = OP;

                alu_src_op1_o   = ALU_SRC_RS1;
                alu_src_op2_o   = ALU_SRC_RS2;
                alu_func_o      = alu_func_e'({1'b0, instr_o.itype_s.func3});    
                base_reg_src_o  = BASE_REG_SRC_ALU_RESULT; 
            end
        endcase
    end // Comb end


endmodule
