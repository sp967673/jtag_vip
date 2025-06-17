
`ifndef JTAG_SEQUENCE_SV
`define JTAG_SEQUENCE_SV

class jtag_base_sequence extends uvm_sequence #(jtag_transaction);
    
    `uvm_object_utils(jtag_base_sequence)
    
    function new(string name = "jtag_base_sequence");
      super.new(name);
    endfunction
    
endclass

class jtag_reset_sequence extends jtag_base_sequence;
    
    `uvm_object_utils(jtag_reset_sequence)
    
    function new(string name = "jtag_reset_sequence");
      super.new(name);
    endfunction
    
    virtual task body();
      jtag_transaction trans;
      trans = jtag_transaction::type_id::create("trans");
      start_item(trans);
      assert(trans.randomize() with {operation == jtag_transaction::JTAG_RESET;});
      finish_item(trans);
    endtask
    
endclass

class jtag_ir_scan_sequence extends jtag_base_sequence;
    
    rand bit [31:0] instruction;
    rand int num_bits;
    
    `uvm_object_utils_begin(jtag_ir_scan_sequence)
      `uvm_field_int(instruction, UVM_ALL_ON)
      `uvm_field_int(num_bits, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "jtag_ir_scan_sequence");
      super.new(name);
    endfunction
    
    virtual task body();
      jtag_transaction trans;
      trans = jtag_transaction::type_id::create("trans");
      start_item(trans);
      assert(trans.randomize() with {
        operation == jtag_transaction::JTAG_IR_SCAN;
        data_in == local::instruction;
        num_bits == local::num_bits;
      });
      finish_item(trans);
    endtask
    
endclass

  class jtag_dr_scan_sequence extends jtag_base_sequence;
    
    rand bit [31:0] wdata;
    rand int num_bits;
    bit [31:0] rdata;
    
    `uvm_object_utils_begin(jtag_dr_scan_sequence)
      `uvm_field_int(wdata, UVM_ALL_ON)
      `uvm_field_int(num_bits, UVM_ALL_ON)
      `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "jtag_dr_scan_sequence");
      super.new(name);
    endfunction
    
    virtual task body();
      jtag_transaction trans;
      trans = jtag_transaction::type_id::create("trans");
      start_item(trans);
      assert(trans.randomize() with {
        operation == jtag_transaction::JTAG_DR_SCAN;
        data_in == local::wdata;
        num_bits == local::num_bits;
      });
      finish_item(trans);

      rdata = trans.data_out;
      `uvm_info("JTAG_DR_SEQ", $sformatf("DR - Write: 0x%0h, Read: 0x%0h, bits: %0d", wdata, rdata, num_bits), UVM_MEDIUM)
    endtask

    function bit [31:0] get_read_data();
        return rdata;
    endfunction: get_read_data
    
endclass

`endif //JTAG_SEQUENCE_SV
