
`ifndef JTAG_IF_SV
`define JTAG_IF_SV

interface jtag_if(input logic tck, input logic trst_n);
    logic tms;
    logic tdi;
    logic tdo;
    logic tdo_en; // TDO enable (for bidirectional pin implementation)

    // Clocking blocks for driver and monitor synchronization
    clocking drv_cb @(posedge tck);
        output tms, tdi;
        input tdo;
    endclocking

    clocking mon_cb @(posedge tck);
        input tms, tdi, tdo;
    endclocking

    // Modport for driver
    modport DRV(clocking drv_cb, input tck, input trst_n);

    // Modport for monitor
    modport MON(clocking mon_cb, input tck, input trst_n);

    // Initialization
    initial begin
        tms = 1'b0;
        tdi = 1'b0;
        tdo_en = 1'b0;
    end
endinterface

`endif //JTAG_IF_SV
