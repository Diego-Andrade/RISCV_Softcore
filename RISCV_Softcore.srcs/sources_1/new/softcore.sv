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
    import rv32i_functions::*;
    import rv32i_opcode::*;
(
    input logic clk_i,
    input logic reset_i
    
    
);

// ==== Controller ===============================
    // ---- Control Unit FSM ---------------------
    // TODO: Replace with pipeline
    
    /*
     // Control Signals
       input logic         clk_i,          // Clock
       input logic         reset_i,        // Sync reset
       input logic         intr_i,         // Sync interrupt 
   
       // Instruction info
       input opcode_e      opcode_i,       // Opcode
       input csr_func_e    csr_func_i,     // Func3 bits which are used for CSR codes
       
       // Program Counter
       output logic        pc_w_o,         // Write enable
       
       // Base Registers
       output logic        br_w_o,         // Write enable
       
       // Memory
       output logic        mem_we2_o,      // Write enable
                           mem_rden1_o,    // Read 1 enable
                           mem_rden2_o,    // Read 2 
   
       // Other System outputs
       output logic        csr_w_o,        // Control and Status Register write enable
       output logic        intr_taken_o    // Signal for interrupt taken
    */

    cu_fsm cu_fsm();



// ==== Fetch ====================================
    // ---- Program Counter module ---------------
    logic   pc_write;
    word    pc_next;
    word    pc;

    prog_counter prog_counter(
        .clk_i(clk_i), .reset_i(reset_i), 
        .w_en_i(pc_write), .w_data_i(pc_next),
        .prog_count_o(pc));

    
// ==== Decode ===================================
    word raw_instr;    // Instruction from memory at address pc

    // ---- Control Unit decoder -----------------
    logic       cu_alu_src_op1;
    logic [1:0] cu_alu_src_op2;
    alu_func_e  cu_alu_func;
    logic [3:0] cu_base_reg_src;
    instruction_u decoded_instr;

    cu_decoder cu_decoder(
        .raw_instr(raw_instr),
        .alu_src_op1_o(cu_alu_src_op1), .alu_src_op2_o(cu_alu_src_op2), .alu_func_o(cu_alu_func),
        .base_reg_src_o(cu_base_reg_src),
        .instr_o(decoded_instr)
        );

    // ---- Base Registers ----------------------- 
    word base_reg_data;
    word rs1;
    word rs2;

    base_regs base_regs(
        .clk_i(clk_i), .reset_i(reset_i),
        .r_addr1_i(instr.rtype_s.rs1_addr), .r_data1_o(rs1),                        // Using R-Type as overload
        .r_addr2_i(instr.rtype_s.rs2_addr), .r_data2_o(rs2),                        // ..
        .w_en_i(), .w_addr_i(instr.rtype_s.rd_addr), .w_data_i(base_reg_data));     // ..

    // ---- ALU source 1 mux ---------------------
    word alu_op1;
    assign alu_op1 = (cu_alu_src_op1 == cu_decoder.ALU_SRC_RS1) ? rs1 : 0;    // TODO: link
    
    // ---- ALU source 2 mux -----------------------
    word alu_op2;
    always_comb
    case (cu_alu_src_op2)
        cu_decoder.ALU_SRC_RS2:         alu_op2 = rs2;
        cu_decoder.ALU_SRC_I_IMMED:     alu_op2 = 0;    // TODO: link
        cu_decoder.ALU_SRC_S_IMMED:     alu_op2 = 0;    // TODO: link
        cu_decoder.ALU_SRC_PC:          alu_op2 = 0;    // TODO: link
    endcase
    
// ==== Execute ==================================
    // ---- ALU module ---------------------------
    word alu_result;

    alu alu(
        .op1_i(alu_op1), .op2_i(alu_op2), .alu_func_i(cu_alu_func),
        .result_o(alu_result));
    
    // ---- PC next generation -------------------
    // Broken out to prepare for pipelining
    always_comb
    case (instr.jtype_s.opcode)
        JALR: pc_next = {{20{instr.itype_s.imm12[11]}}, instr.itype_s.imm12} + alu_op1;
        BRANCH: pc_next = alu_result ? 
            pc + {{12{instr.btype_s.imm12[11]}}, instr.btype_s.imm12[11:1], 1'b0} :
            pc + 4; 
        JAL: pc_next = pc + {{12{instr.jtype_s.imm20}}, instr.jtype_s.imm20[19:1], 1'b0};

        default: pc_next = pc + 4;
    endcase
    
    // TODO
    // ---- Branch Cond --------------------------


// ==== Memory ===================================
    // TODO
    // ---- Memory module ------------------------


// ==== Writeback ================================
    // ---- Base Register source mux -------------
    
    
    
endmodule
