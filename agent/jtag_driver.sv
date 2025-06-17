
`ifndef JTAG_DRIVER_SV
`define JTAG_DRIVER_SV

class jtag_driver extends uvm_driver #(jtag_transaction);
  
  virtual jtag_if vif;
  jtag_config cfg;
  
  `uvm_component_utils(jtag_driver)
  
  function new(string name = "jtag_driver", uvm_component parent = null);
    super.new(name, parent);
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
    forever begin
      seq_item_port.get_next_item(req);
      drive_transaction(req);
      seq_item_port.item_done();
    end
  endtask
  
  virtual task drive_transaction(jtag_transaction trans);
    case (trans.operation)
      jtag_transaction::JTAG_RESET: drive_reset();
      jtag_transaction::JTAG_IDLE: drive_idle();
      jtag_transaction::JTAG_DR_SCAN: drive_dr_scan(trans);
      jtag_transaction::JTAG_IR_SCAN: drive_ir_scan(trans);
      jtag_transaction::JTAG_CUSTOM: drive_custom(trans);
    endcase
  endtask
  
  virtual task drive_reset();
    repeat (5) begin
      @(posedge vif.tck);
      vif.tms <= 1'b1;
      vif.tdi <= 1'b0;
    end
    @(posedge vif.tck);
    vif.tms <= 1'b0;
    vif.tdi <= 1'b0;
  endtask
  
  virtual task drive_idle();
    @(posedge vif.tck);
    vif.tms <= 1'b0;
    vif.tdi <= 1'b0;
  endtask
  
  virtual task drive_dr_scan(jtag_transaction trans);
    // Go to DR-Scan state
    @(posedge vif.tck); vif.tms <= 1'b1; // Select-DR
    @(posedge vif.tck); vif.tms <= 1'b0; // Capture-DR
    @(posedge vif.tck); vif.tms <= 1'b0; // Shift-DR
    
    // Shift data
    for (int i = 0; i < trans.num_bits; i++) begin
      @(posedge vif.tck);
      vif.tdi <= trans.data_in[i];
      if (i == trans.num_bits - 1)
        vif.tms <= 1'b1; // Exit1-DR
      else
        vif.tms <= 1'b0;
      trans.data_out[i] = vif.tdo;
    end
    
    // Return to idle
    @(posedge vif.tck); vif.tms <= 1'b1; // Update-DR
    @(posedge vif.tck); vif.tms <= 1'b0; // Run-Test/Idle
  endtask
  
  virtual task drive_ir_scan(jtag_transaction trans);
    // Go to IR-Scan state
    @(posedge vif.tck); vif.tms <= 1'b1; // Select-DR
    @(posedge vif.tck); vif.tms <= 1'b1; // Select-IR
    @(posedge vif.tck); vif.tms <= 1'b0; // Capture-IR
    @(posedge vif.tck); vif.tms <= 1'b0; // Shift-IR
    
    // Shift instruction
    for (int i = 0; i < trans.num_bits; i++) begin
      @(posedge vif.tck);
      vif.tdi <= trans.data_in[i];
      if (i == trans.num_bits - 1)
        vif.tms <= 1'b1; // Exit1-IR
      else
        vif.tms <= 1'b0;
      trans.data_out[i] = vif.tdo;
    end
    
    // Return to idle
    @(posedge vif.tck); vif.tms <= 1'b1; // Update-IR
    @(posedge vif.tck); vif.tms <= 1'b0; // Run-Test/Idle
  endtask
  
  virtual task drive_custom(jtag_transaction trans);
    @(posedge vif.tck);
    vif.tms <= trans.tms;
    vif.tdi <= trans.tdi;
  endtask
  
endclass

`endif //JTAG_DRIVER_SV
