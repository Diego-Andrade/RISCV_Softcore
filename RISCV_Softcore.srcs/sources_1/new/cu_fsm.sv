//////////////////////////////////////////////////////////////////////////////////
// Engineer: Diego Andrade (bets636@gmail.com)
// 
// Create Date: 04/09/2023 08:32:52 PM
// Design Name: RISCV Softcore
// Module Name: cu_fsm
// Project Name: RISCV_Softcore
// Target Devices: Xilinx Artix-7
// Description: The control unit for CPU. Implemented as FSM
// 
// Dependencies: riscv_isa.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cu_fsm
    import rv32i_opcode::*;
    import rv32i_functions::*;
(
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
);

    // FSM states
    typedef enum {FETCH, EXEC, WRITEBACK, INTR} state_e;
    
    // State trackers
    state_e present_state = FETCH, 
            next_state    = FETCH;
    
    // Transition state on clock posedge
    always_ff @ (posedge clk_i) begin
        present_state   <= reset_i ?    FETCH   :   next_state;
    end
    
    // FSM logic
    always_comb begin
        // Defaults: Unasserted unless otherwise needed by branch
        pc_w_o          = '0;
        br_w_o          = '0;
        mem_we2_o       = '0;
        mem_rden1_o     = '0;
        mem_rden2_o     = '0;
        csr_w_o         = '0;
        intr_taken_o    = '0;

        next_state      = FETCH;    // Continue processing instructions

        // Update outpus depending on state and inputs
        unique case (present_state)
            // Handle interrupt jumping to ISR
            INTR: begin
                pc_w_o          = '1;
                intr_taken_o    = '1;
                next_state      = FETCH;         
            end

            // Handle instruction fetch from memory
            FETCH: begin
                mem_rden1_o     = '1;
                next_state      = EXEC;
            end
            
            // Handle updating Register File since extra clock needed from ALU computation
            // to write in Register FIle
            WRITEBACK: begin
                pc_w_o          = '1;
                br_w_o          = '1;
                next_state      = intr_i ?  INTR    :   FETCH;
            end
            
            // Handle executing command
            EXEC: begin
                case (opcode_i)
                    // Memory reading and Register File writing event, trigger writeback,
                    // ignoring incoming interrupts
                    LOAD: begin
                        mem_rden2_o     = '1;
                        next_state      = WRITEBACK;
                    end
                    
                    // Memory write
                    STORE: begin
                        mem_we2_o       = '1;
                        next_state      = intr_i ?  INTR    :   FETCH;
                    end
                    
                    // TODO: Verify
                    SYSTEM: begin
                        if (csr_func_i == _RW) begin
                            csr_w_o     = '1;
                        end
                    end
                    
                    // ALU and Branch/Jump operations
                    default: begin
                        next_state      = intr_i ?  INTR    :   FETCH;
                    end
                endcase
            end // EXEC end
        endcase // FSM end
    end // Comb end


endmodule
