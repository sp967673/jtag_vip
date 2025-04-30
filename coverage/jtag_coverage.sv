
`ifndef JTAG_COVERAGE
`define JTAG_COVERAGE

class jtag_coverage extends uvm_subscriber #(jtag_transaction);
    `uvm_component_utils(jtag_coverage)
    
    jtag_transaction tr;
    
    // Covergroup for JTAG commands
    covergroup jtag_cmd_cg;
        cmd: coverpoint tr.cmd {
            bins ir_scan = {jtag_transaction::IR_SCAN};
            bins dr_scan = {jtag_transaction::DR_SCAN};
            bins reset = {jtag_transaction::RESET};
            bins idle = {jtag_transaction::IDLE};
            bins runtest = {jtag_transaction::RUNTEST};
        }
    endgroup
    
    // Covergroup for IR/DR lengths
    covergroup jtag_length_cg;
        ir_len: coverpoint tr.ir_len {
            bins small = {[4:8]};
            bins medium = {[9:16]};
            bins large = {[17:32]};
        }
        dr_len: coverpoint tr.dr_len {
            bins small = {[1:8]};
            bins medium = {[9:32]};
            bins large = {[33:64]};
        }
    endgroup
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        jtag_cmd_cg = new();
        jtag_length_cg = new();
    endfunction
    
    function void write(jtag_transaction t);
        tr = t;
        jtag_cmd_cg.sample();
        if(tr.cmd inside {jtag_transaction::IR_SCAN, jtag_transaction::DR_SCAN}) begin
            jtag_length_cg.sample();
        end
    endfunction
endclass

`endif //JTAG_COVERAGE_SV
