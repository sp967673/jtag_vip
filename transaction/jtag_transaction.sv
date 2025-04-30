
`ifndef JTAG_TRANSACTION_SV
`define JTAG_TRANSACTION_SV

class jtag_transaction extends uvm_sequence_item;
    typedef enum {IR_SCAN, DR_SCAN, RESET, IDLE, RUNTEST} jtag_cmd_t;
    
    rand jtag_cmd_t cmd;
    rand bit [31:0] data_in;
    rand uint ir_len;
    rand uint dr_len;
    rand uint idle_cycles;
    bit [31:0] data_out;
    
    // Constraints
    constraint reasonable_lengths {
        ir_len inside {[4:32]};
        dr_len inside {[1:64]};
        idle_cycles inside {[1:100]};
    }
    
    `uvm_object_utils_begin(jtag_transaction)
        `uvm_field_enum(jtag_cmd_t, cmd, UVM_ALL_ON)
        `uvm_field_int(data_in, UVM_ALL_ON)
        `uvm_field_int(ir_len, UVM_ALL_ON)
        `uvm_field_int(dr_len, UVM_ALL_ON)
        `uvm_field_int(idle_cycles, UVM_ALL_ON)
        `uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "jtag_transaction");
        super.new(name);
    endfunction
endclass

`endif //JTAG_TRANSACTION_SV
