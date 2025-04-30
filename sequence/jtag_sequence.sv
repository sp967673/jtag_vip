
`ifndef JTAG_SEQUENCE_SV
`define JTAG_SEQUENCE_SV

class jtag_base_sequence extends uvm_sequence #(jtag_transaction);
    `uvm_object_utils(jtag_base_sequence)
    
    function new(string name = "jtag_base_sequence");
        super.new(name);
    endfunction
    
    task body();
        // Base sequence with common functionality
    endtask
endclass

class jtag_reset_sequence extends jtag_base_sequence;
    `uvm_object_utils(jtag_reset_sequence)
    
    function new(string name = "jtag_reset_sequence");
        super.new(name);
    endfunction
    
    task body();
        jtag_transaction tr;
        tr = jtag_transaction::type_id::create("tr");
        start_item(tr);
        tr.cmd = jtag_transaction::RESET;
        finish_item(tr);
    endtask
endclass

class jtag_ir_dr_sequence extends jtag_base_sequence;
    `uvm_object_utils(jtag_ir_dr_sequence)
    
    rand bit [31:0] ir_data;
    rand bit [63:0] dr_data;
    rand uint ir_length = 5;
    rand uint dr_length = 32;
    
    function new(string name = "jtag_ir_dr_sequence");
        super.new(name);
    endfunction
    
    task body();
        jtag_transaction tr;
        
        // IR scan
        tr = jtag_transaction::type_id::create("ir_tr");
        start_item(tr);
        tr.cmd = jtag_transaction::IR_SCAN;
        tr.data_in = ir_data;
        tr.ir_len = ir_length;
        finish_item(tr);
        
        // DR scan
        tr = jtag_transaction::type_id::create("dr_tr");
        start_item(tr);
        tr.cmd = jtag_transaction::DR_SCAN;
        tr.data_in = dr_data;
        tr.dr_len = dr_length;
        finish_item(tr);
    endtask
endclass

`endif //JTAG_SEQUENCE_SV
