
`ifndef JTAG_COVERAGE
`define JTAG_COVERAGE

class jtag_coverage extends uvm_subscriber #(jtag_transaction);
    `uvm_component_utils(jtag_coverage)
    
    jtag_transaction trans;
    
    covergroup jtag_operation_cg;
      operation_cp: coverpoint trans.operation {
        bins reset = {jtag_transaction::JTAG_RESET};
        bins idle = {jtag_transaction::JTAG_IDLE};
        bins dr_scan = {jtag_transaction::JTAG_DR_SCAN};
        bins ir_scan = {jtag_transaction::JTAG_IR_SCAN};
        bins custom = {jtag_transaction::JTAG_CUSTOM};
      }
    endgroup

    covergroup jtag_data_cg;
      tms_cp: coverpoint trans.tms;
      tdi_cp: coverpoint trans.tdi;
      tdo_cp: coverpoint trans.tdo;
      num_bits_cp: coverpoint trans.num_bits {
        bins s = {[1:8]};
        bins m = {[9:16]};
        bins l = {[17:32]};
      }
      data_in_cp: coverpoint trans.data_in {
        bins all_zeros = {32'h00000000};
        bins all_ones = {32'hFFFFFFFF};
        bins others = default;
      }
    endgroup
    
    covergroup jtag_transition_cg;
      tms_transition_cp: coverpoint trans.tms {
        bins low_to_high = (0 => 1);
        bins high_to_low = (1 => 0);
        bins stay_low = (0 => 0);
        bins stay_high = (1 => 1);
      }
    endgroup
    
    function new(string name = "jtag_coverage", uvm_component parent = null);
      super.new(name, parent);
      jtag_operation_cg = new();
      jtag_data_cg = new();
      jtag_transition_cg = new();
    endfunction
    
    function void write(jtag_transaction t);
      trans = t;
      jtag_operation_cg.sample();
      jtag_data_cg.sample();
      jtag_transition_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("JTAG_COV", $sformatf("Operation coverage: %.2f%%", 
                jtag_operation_cg.get_coverage()), UVM_LOW)
      `uvm_info("JTAG_COV", $sformatf("Data coverage: %.2f%%", 
                jtag_data_cg.get_coverage()), UVM_LOW)
      `uvm_info("JTAG_COV", $sformatf("Transition coverage: %.2f%%", 
                jtag_transition_cg.get_coverage()), UVM_LOW)
    endfunction

endclass

`endif //JTAG_COVERAGE_SV
