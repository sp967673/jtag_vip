
`ifndef JTAG_SCOREBOARD_SV
`define JTAG_SCOREBOARD_SV

class jtag_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(jtag_scoreboard)
    
    uvm_analysis_imp #(jtag_transaction, jtag_scoreboard) ap_imp;
    
    // Scoreboard variables
    int transactions_count;
    int reset_count;
    int dr_scan_count;
    int ir_scan_count;
    
    function new(string name = "jtag_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      ap_imp = new("ap_imp", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      transactions_count = 0;
      reset_count = 0;
      dr_scan_count = 0;
      ir_scan_count = 0;
    endfunction
    
    // Compare received transactions with expected
    function void write(jtag_transaction trans);
      transactions_count++;
      
      // Count different operation types
      case (trans.operation)
        jtag_transaction::JTAG_RESET: reset_count++;
        jtag_transaction::JTAG_DR_SCAN: dr_scan_count++;
        jtag_transaction::JTAG_IR_SCAN: ir_scan_count++;
      endcase
      
      `uvm_info("JTAG_SB", $sformatf("Received transaction: %s", trans.sprint()), UVM_LOW)
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("JTAG_SB", $sformatf("Total transactions: %0d", transactions_count), UVM_LOW)
      `uvm_info("JTAG_SB", $sformatf("Reset operations: %0d", reset_count), UVM_LOW)
      `uvm_info("JTAG_SB", $sformatf("DR scan operations: %0d", dr_scan_count), UVM_LOW)
      `uvm_info("JTAG_SB", $sformatf("IR scan operations: %0d", ir_scan_count), UVM_LOW)
    endfunction
endclass

`endif //JTAG_SCOREBOARD_SV
