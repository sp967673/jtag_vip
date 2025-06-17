
`ifndef JTAG_TRANSACTION_SV
`define JTAG_TRANSACTION_SV

class jtag_transaction extends uvm_sequence_item;
  
  // JTAG signals
  rand bit        tms;
  rand bit        tdi;
  bit             tdo;
  rand int        num_bits;
  rand bit [31:0] data_in;
  bit [31:0]      data_out;
  
  // Transaction types
  typedef enum {
    JTAG_RESET,
    JTAG_IDLE,
    JTAG_DR_SCAN,
    JTAG_IR_SCAN,
    JTAG_CUSTOM
  } jtag_operation_t;
  
  rand jtag_operation_t operation;
  
  // Constraints
  constraint valid_num_bits {
      num_bits inside {[1:32]};
  }
  
  constraint valid_operation {
    operation inside {JTAG_RESET, JTAG_IDLE, JTAG_DR_SCAN, JTAG_IR_SCAN};
  }
  
  `uvm_object_utils_begin(jtag_transaction)
    `uvm_field_int(tms, UVM_ALL_ON)
    `uvm_field_int(tdi, UVM_ALL_ON)
    `uvm_field_int(tdo, UVM_ALL_ON)
    `uvm_field_int(num_bits, UVM_ALL_ON)
    `uvm_field_int(data_in, UVM_ALL_ON)
    `uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_field_enum(jtag_operation_t, operation, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "jtag_transaction");
    super.new(name);
  endfunction
  
endclass

`endif //JTAG_TRANSACTION_SV
