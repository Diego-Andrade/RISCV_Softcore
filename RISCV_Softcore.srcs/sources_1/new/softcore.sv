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
    import rv32i::*;
    import rv32i_functions::*;
    import rv32i_opcode::*;
(
    input   logic   clk_i,
    input   logic   reset_i
    
    
);

    // ---- Important signals --------------------  // TODO: Name change
    word            prog_count;
    word            prog_count_next;

    word            instr_raw;
    instruction_u   instr_decoded;
    word            instr_immed;

    word            alu_result;


// TODO: Replace with pipeline
// ---- Controller -------------------------------
    logic prog_count_w_en;
    logic base_reg_w_en;
    logic mem_r_en1;
    logic mem_r_en2;
    logic mem_w_en2;

    cu_fsm cu_fsm(
        .clk_i(clk_i), .reset_i(reset_i), .intr_i(1'b0),    // TODO link interrupt
        .opcode_i(instr_decoded.rtype_s.opcode),            // Using R-Type as overload
//        .csr_func_i(),
        .prog_count_w_en_o(prog_count_w_en),
        .base_reg_w_en_o(base_reg_w_en),
        .mem_r_en1_o(mem_r_en1),
        .mem_r_en2_o(mem_r_en2), .mem_w_en2_o(mem_w_en2)
//        .csr_w_o(),                                       // TOOD: Link 
//        .intr_taken_o()                                   // TODO: Link
    );

// ==== Fetch ====================================
    // ---- Program Counter Mux ------------------
    word pc_next;
    always_comb
    case (instr_decoded.rtype_s.opcode)
        JAL:        prog_count_next = prog_count + instr_immed;
        JALR:       prog_count_next = alu_result & 32'hfffffffe;
        BRANCH:     prog_count_next =  (alu_result == !instr_decoded.btype_s.func3[0]) ? 
                        prog_count + instr_immed : prog_count + 32'd4;
        default:    prog_count_next = prog_count + 4;
    endcase

    // ---- Program Counter module ---------------
    prog_counter prog_counter(
        .clk_i(clk_i), .reset_i(reset_i), 
        .w_en_i(prog_count_w_en), .w_data_i(pc_next),
        .prog_count_o(prog_count));

// ==== Decode ===================================
    // ---- Control Unit decoder -----------------
    logic                   cu_alu_src_op1;
    logic           [1:0]   cu_alu_src_op2;
    alu_func_e              cu_alu_func;
    logic           [3:0]   cu_base_reg_src;

    cu_decoder cu_decoder(
        .raw_instr_i(instr_raw),
        .alu_src_op1_o(cu_alu_src_op1), .alu_src_op2_o(cu_alu_src_op2),
        .alu_func_o(cu_alu_func),
        .base_reg_src_o(cu_base_reg_src),
        .instr_o(instr_decoded),
        .immed_o(instr_immed));

    // ---- Base Registers ----------------------- 
    word rs1;
    word rs2;
    word writeback_base_reg_data;

    base_regs base_regs(
        .clk_i(clk_i), .reset_i(reset_i),
        .r_addr1_i(instr_decoded.rtype_s.rs1_addr), .r_data1_o(rs1),        // Using R-Type as overload
        .r_addr2_i(instr_decoded.rtype_s.rs2_addr), .r_data2_o(rs2),        // ..
        .w_en_i(base_reg_w_en), .w_addr_i(instr_decoded.rtype_s.rd_addr),   // ..
        .w_data_i(writeback_base_reg_data));

    // ---- ALU source 1 mux ---------------------
    word alu_op1;
    assign alu_op1 = (cu_alu_src_op1 == cu_decoder.ALU_SRC_RS1) ? rs1 : instr_immed;
    
    // ---- ALU source 2 mux -----------------------
    word alu_op2;
    always_comb
    case (cu_alu_src_op2)
        cu_decoder.ALU_SRC_RS2:         alu_op2 = rs2;
        cu_decoder.ALU_SRC_IMMED:       alu_op2 = instr_immed;
        cu_decoder.ALU_SRC_PC:          alu_op2 = prog_count;

        default:                        alu_op2 = 0;
    endcase
    
// ==== Execute ==================================
    // ---- ALU module ---------------------------
    alu alu(
        .op1_i(alu_op1), .op2_i(alu_op2), .alu_func_i(cu_alu_func),
        .result_o(alu_result));

// ==== Memory ===================================
    // TODO
    // ---- Memory module ------------------------
    word mem_data2;
    
    ram_dualport mem(
        .clk_i(clk_i), .reset(reset_i),
        .r_en1_i(mem_r_en1), .addr1_i(prog_count), .r_data1_o(instr_raw),
        .r_en2_i(mem_r_en2), .addr2_i(alu_result), 
        .size2_i(instr_decoded.stype_s.func3), .r_data2_o(mem_data2),
        .w_en2_i(mem_w_en2), .w_data2_i(rs2));
// ==== Writeback ================================
    // ---- Base Register source mux -------------
    always_comb
    case (cu_base_reg_src)
        cu_decoder.BASE_REG_SRC_ALU_RESULT: writeback_base_reg_data = alu_result;
        cu_decoder.BASE_REG_SRC_MEM:        writeback_base_reg_data = mem_data2;
        cu_decoder.BASE_REG_SRC_PC_4:       writeback_base_reg_data = prog_count + 4;

        default:                            writeback_base_reg_data = 0;
    endcase
    
endmodule
