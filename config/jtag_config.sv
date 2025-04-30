
`ifndef JTAG_CONFIG_SV
`define JTAG_CONFIG_SV

class jtag_config extends uvm_object;
    // Virtual interface
    virtual jtag_if vif;
    
    // Configuration parameters
    bit has_coverage = 1;
    bit has_scoreboard = 1;
    bit active_passive = UVM_ACTIVE;
    
    // Timing parameters
    int tck_period = 100; // in ns
    int setup_time = 10;  // in ns
    int hold_time = 10;   // in ns
    
    `uvm_object_utils(jtag_config)
    
    function new(string name = "jtag_config");
        super.new(name);
    endfunction
endclass

`endif //JTAG_CONFIG_SV
