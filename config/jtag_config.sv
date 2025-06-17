
`ifndef JTAG_CONFIG_SV
`define JTAG_CONFIG_SV

class jtag_config extends uvm_object;
  
  // Configuration parameters
  int unsigned tck_period = 100; // TCK period in ns
  bit is_active = 1;
  bit has_monitor = 1;
  bit has_coverage = 1;
  bit has_scoreboard = 1;
  
  // Virtual interface
  virtual jtag_if vif;
  
  `uvm_object_utils_begin(jtag_config)
    `uvm_field_int(tck_period, UVM_ALL_ON)
    `uvm_field_int(is_active, UVM_ALL_ON)
    `uvm_field_int(has_monitor, UVM_ALL_ON)
    `uvm_field_int(has_coverage, UVM_ALL_ON)
    `uvm_field_int(has_scoreboard, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "jtag_config");
    super.new(name);
  endfunction
  
endclass

`endif //JTAG_CONFIG_SV
