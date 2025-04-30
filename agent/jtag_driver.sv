
`ifndef JTAG_DRIVER_SV
`define JTAG_DRIVER_SV

class jtag_driver extends uvm_driver #(jtag_transaction);
    `uvm_component_utils(jtag_driver)
    
    virtual jtag_if vif;
    jtag_config cfg;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
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
        reset_jtag();
        forever begin
            seq_item_port.get_next_item(req);
            execute_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    task reset_jtag();
        vif.trst_n = 0;
        #(cfg.tck_period * 5);
        vif.trst_n = 1;
        // Put TAP in Run-Test/Idle state
        vif.drv_cb.tms <= 1;
        @(vif.drv_cb);
        vif.drv_cb.tms <= 1;
        @(vif.drv_cb);
        vif.drv_cb.tms <= 0;
        @(vif.drv_cb);
    endtask
    
    task execute_transaction(jtag_transaction tr);
        case(tr.cmd)
            jtag_transaction::RESET:    do_reset(tr);
            jtag_transaction::IR_SCAN: do_ir_scan(tr);
            jtag_transaction::DR_SCAN: do_dr_scan(tr);
            jtag_transaction::IDLE:   do_idle(tr);
            jtag_transaction::RUNTEST: do_run_test(tr);
        endcase
    endtask
    
    task do_reset(jtag_transaction tr);
        vif.drv_cb.tms <= 1;
        repeat(5) @(vif.drv_cb);
    endtask
    
    task do_ir_scan(jtag_transaction tr);
        // Move to Shift-IR state
        vif.drv_cb.tms <= 1; @(vif.drv_cb); // Select-DR
        vif.drv_cb.tms <= 1; @(vif.drv_cb); // Select-IR
        vif.drv_cb.tms <= 0; @(vif.drv_cb); // Capture-IR
        vif.drv_cb.tms <= 0; @(vif.drv_cb); // Shift-IR
        
        // Shift IR data
        for(int i = 0; i < tr.ir_len; i++) begin
            vif.drv_cb.tdi <= tr.data_in[i];
            vif.drv_cb.tms <= (i == tr.ir_len-1);
            @(vif.drv_cb);
        end
        
        // Update to Exit1-IR and then to Run-Test/Idle
        vif.drv_cb.tms <= 1; @(vif.drv_cb); // Exit1-IR
        vif.drv_cb.tms <= 1; @(vif.drv_cb); // Update-IR
        vif.drv_cb.tms <= 0; @(vif.drv_cb); // Run-Test/Idle
    endtask
    
    task do_dr_scan(jtag_transaction tr);
        // Similar to do_ir_scan but for DR scan
        // Implementation omitted for brevity
    endtask
    
    task do_idle(jtag_transaction tr);
        vif.drv_cb.tms <= 0;
        repeat(tr.idle_cycles) @(vif.drv_cb);
    endtask
    
    task do_run_test(jtag_transaction tr);
        vif.drv_cb.tms <= 0;
        repeat(tr.idle_cycles) @(vif.drv_cb);
    endtask
endclass

`endif //JTAG_DRIVER_SV
