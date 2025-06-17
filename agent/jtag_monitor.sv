
`ifndef JTAG_MONITOR_SV
`define JTAG_MONITOR_SV

class jtag_monitor extends uvm_monitor;
  
  virtual jtag_if vif;
  jtag_config cfg;
  
  uvm_analysis_port #(jtag_transaction) ap;
  
  `uvm_component_utils(jtag_monitor)
  
  function new(string name = "jtag_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(jtag_config)::get(this, "", "cfg", cfg))
        `uvm_fatal("NO_CFG", "Configuration object not found")
    if (cfg.vif == null)
        `uvm_fatal("NO_VIF", "Virtual interface is null in configuration")
    vif = cfg.vif;
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    jtag_transaction trans;
    forever begin
      @(posedge vif.tck);
      trans = jtag_transaction::type_id::create("trans");
      trans.tms = vif.tms;
      trans.tdi = vif.tdi;
      trans.tdo = vif.tdo;
      ap.write(trans);
    end
  endtask
  
endclass

`endif //JTAG_MONITOR_SV
