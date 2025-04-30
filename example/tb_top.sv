module tb;
    // Clock and reset
    logic tck;
    logic trst_n;
    
    // Instantiate JTAG interface
    jtag_if jtag_intf(tck, trst_n);
    
    // Generate clock
    initial begin
        tck = 0;
        forever #50 tck = ~tck; // 10MHz clock
    end
    
    // Generate reset
    initial begin
        trst_n = 0;
        #100 trst_n = 1;
    end
    
    // DUT instantiation (example)
    dut_top dut(
        .tck(jtag_intf.tck),
        .trst_n(jtag_intf.trst_n),
        .tms(jtag_intf.tms),
        .tdi(jtag_intf.tdi),
        .tdo(jtag_intf.tdo)
    );
    
    // Import JTAG package
    import jtag_pkg::*;
    
    // Testbench top
    initial begin
        // Set interface in config DB
        uvm_config_db#(virtual jtag_if)::set(null, "uvm_test_top.env.jtag_agent", "vif", jtag_intf);
        
        // Create and set config
        jtag_config cfg = jtag_config::type_id::create("cfg");
        cfg.vif = jtag_intf;
        uvm_config_db#(jtag_config)::set(null, "uvm_test_top.env.jtag_agent", "cfg", cfg);
        
        // Start test
        run_test("jtag_test");
    end
endmodule
