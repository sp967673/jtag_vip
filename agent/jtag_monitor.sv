
`ifndef JTAG_DRIVER_SV
`define JTAG_DRIVER_SV

class jtag_monitor extends uvm_monitor;
    `uvm_component_utils(jtag_monitor)
    
    virtual jtag_if vif;
    jtag_config cfg;
    uvm_analysis_port #(jtag_transaction) ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual jtag_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not set")
        end
        if(!uvm_config_db#(jtag_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Config object not set")
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            jtag_transaction tr;
            monitor_tap(tr);
            ap.write(tr);
        end
    endtask
    
    task monitor_tap(output jtag_transaction tr);
        // Implementation to monitor JTAG TAP state machine and capture transactions
        // This would track the TAP state and capture IR/DR scans
    endtask
endclass

`endif //JTAG_DRIVER_SV
