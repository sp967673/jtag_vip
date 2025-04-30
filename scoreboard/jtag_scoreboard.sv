
`ifndef JTAG_SCOREBOARD_SV
`define JTAG_SCOREBOARD_SV

class jtag_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(jtag_scoreboard)
    
    uvm_analysis_imp #(jtag_transaction, jtag_scoreboard) item_collected_export;
    
    // Expected transactions queue
    jtag_transaction expected_queue[$];
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    // Store expected transactions
    function void store_expected(jtag_transaction tr);
        expected_queue.push_back(tr);
    endfunction
    
    // Compare received transactions with expected
    function void write(jtag_transaction received_tr);
        jtag_transaction expected_tr;
        
        if(expected_queue.size() == 0) begin
            `uvm_error("SCBD", $sformatf("Received unexpected transaction: %s", received_tr.sprint()))
            return;
        end
        
        expected_tr = expected_queue.pop_front();
        
        if(!received_tr.compare(expected_tr)) begin
            `uvm_error("SCBD", $sformatf("Transaction mismatch!\nExpected: %s\nReceived: %s", 
                                        expected_tr.sprint(), received_tr.sprint()))
        end
        else begin
            `uvm_info("SCBD", "Transaction matched", UVM_HIGH)
        end
    endfunction
endclass

`endif //JTAG_SCOREBOARD_SV
