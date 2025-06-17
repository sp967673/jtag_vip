
`ifndef JTAG_AGENT_SV
`define JTAG_AGENT_SV

class jtag_agent extends uvm_agent;

    `uvm_component_utils(jtag_agent)
    
    jtag_driver driver;
    jtag_monitor monitor;
    jtag_sequencer sequencer;
    jtag_config cfg;
    jtag_coverage coverage;
    virtual jtag_if vif;

    uvm_analysis_port #(jtag_transaction) ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);
        
        if (!uvm_config_db#(jtag_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NO_CFG", "Configuration object not found")

        if (!uvm_config_db#(virtual jtag_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface is null in configuration")
        
        cfg.vif = vif;
      
        // Create monitor if required
        if (cfg.has_monitor) begin
            monitor = jtag_monitor::type_id::create("monitor", this);
            uvm_config_db#(jtag_config)::set(this, "monitor", "cfg", cfg);
        end
        
        // Create coverage if required
        if (cfg.has_coverage) begin
            coverage = jtag_coverage::type_id::create("coverage", this);
        end
        
        // Create driver and sequencer if active
        if (cfg.is_active == UVM_ACTIVE) begin
            driver = jtag_driver::type_id::create("driver", this);
            sequencer = jtag_sequencer::type_id::create("sequencer", this);
            uvm_config_db#(jtag_config)::set(this, "driver", "cfg", cfg);
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if(cfg.is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end

        // Connect monitor analysis port
        if (cfg.has_monitor) begin
            monitor.ap.connect(ap);
            if (cfg.has_coverage)
                monitor.ap.connect(coverage.analysis_export);
        end
    endfunction

endclass

`endif //JTAG_AGENT_SV
