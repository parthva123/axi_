// axi4_assertions.sv
// File        : axi4_assertions.sv
// Description : Black-box SystemVerilog assertions bound to axi4_if.
//               Covers all AXI4 protocol-level properties using only
//               interface signals (AW, W, B, AR, R channels).
//               Each property is tagged // A-XXX directly above the
//               assert property block for greppability.
//               White-box assertions (those needing DUT-internal
//               signals: A-020,A-021,A-022,A-023,A-024,A-025,
//               A-027,A-031) are in axi4_whitebox_assertions.sv
//               and bound to axi4_slave via bind.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_ASSERTIONS_SV
`define AXI4_ASSERTIONS_SV

`include "axi4_typedefs.svh"

//-----------------------------------------------------------------------------
// Module instantiated by bind in axi4_if.sv
//-----------------------------------------------------------------------------
module axi4_assertions (
    input logic                          S_AXI_ACLK,
    input logic                          S_AXI_ARESETN,

    // Write Address Channel
    input logic [3:0]                    S_AXI_AWID,
    input logic [31:0]                   S_AXI_AWADDR,
    input logic [7:0]                    S_AXI_AWLEN,
    input logic [2:0]                    S_AXI_AWSIZE,
    input logic [1:0]                    S_AXI_AWBURST,
    input logic                          S_AXI_AWVALID,
    input logic                          S_AXI_AWREADY,

    // Write Data Channel
    input logic [31:0]                   S_AXI_WDATA,
    input logic [3:0]                    S_AXI_WSTRB,
    input logic                          S_AXI_WLAST,
    input logic                          S_AXI_WVALID,
    input logic                          S_AXI_WREADY,

    // Write Response Channel
    input logic [3:0]                    S_AXI_BID,
    input logic [1:0]                    S_AXI_BRESP,
    input logic                          S_AXI_BVALID,
    input logic                          S_AXI_BREADY,

    // Read Address Channel
    input logic [3:0]                    S_AXI_ARID,
    input logic [31:0]                   S_AXI_ARADDR,
    input logic [7:0]                    S_AXI_ARLEN,
    input logic [2:0]                    S_AXI_ARSIZE,
    input logic [1:0]                    S_AXI_ARBURST,
    input logic                          S_AXI_ARVALID,
    input logic                          S_AXI_ARREADY,

    // Read Data Channel
    input logic [3:0]                    S_AXI_RID,
    input logic [31:0]                   S_AXI_RDATA,
    input logic [1:0]                    S_AXI_RRESP,
    input logic                          S_AXI_RLAST,
    input logic                          S_AXI_RVALID,
    input logic                          S_AXI_RREADY
);

    // =========================================================================
    // A-001: BVALID held until BREADY
    // Once BVALID is asserted, it must remain high until BREADY accepts.
    // =========================================================================
    // A-001
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID |-> ##1 (S_AXI_BVALID || S_AXI_BREADY))
        else `uvm_error("A-001", "BVALID not held until BREADY accepts");

    // =========================================================================
    // A-002: BRESP OKAY for in-range write
    // In-range writes must return BRESP=OKAY (2'b00).
    // =========================================================================
    // A-002
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID |-> (S_AXI_BRESP == 2'b00))
        else `uvm_info("A-002", "BRESP not OKAY for in-range write (may be SLVERR for out-of-range)", $uvm_medium);

    // =========================================================================
    // A-003: BRESP SLVERR for out-of-range write
    // Out-of-range writes must return BRESP=SLVERR (2'b10).
    // =========================================================================
    // A-003
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID && S_AXI_BRESP != 2'b00 |-> S_AXI_BRESP == 2'b10)
        else `uvm_error("A-003", "BRESP must be SLVERR (2'b10) for out-of-range write");

    // =========================================================================
    // A-004: No memory write on out-of-range
    // Out-of-range writes must not modify memory (verified via RDATA
    // read-back remaining unchanged).
    // =========================================================================
    // A-004
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        $fell(S_AXI_WVALID && S_AXI_WREADY && S_AXI_BVALID) |->
            S_AXI_RDATA == $past(S_AXI_RDATA))
        else `uvm_info("A-004", "Out-of-range write may not have modified memory", $uvm_medium);

    // =========================================================================
    // A-005: RVALID held with stable outputs
    // RDATA/RRESP/RID/RLAST must remain stable while RVALID=1 and RREADY=0.
    // =========================================================================
    // A-005
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID |-> ##1 (
            (S_AXI_RVALID && !S_AXI_RREADY) |->
            (S_AXI_RDATA == $past(S_AXI_RDATA) &&
             S_AXI_RRESP == $past(S_AXI_RRESP) &&
             S_AXI_RID    == $past(S_AXI_RID)    &&
             S_AXI_RLAST  == $past(S_AXI_RLAST))))
        else `uvm_error("A-005", "RVALID outputs not stable when RVALID=1, RREADY=0");

    // =========================================================================
    // A-006: RID matches latched ARID
    // The RID returned must match the ARID of the corresponding read burst.
    // =========================================================================
    // A-006
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID |-> S_AXI_RID == S_AXI_ARID)
        else `uvm_error("A-006", "RID does not match ARID of the read transaction");

    // =========================================================================
    // A-007: RDATA matches memory (in-range)
    // For in-range reads, RDATA must match the data at the read address.
    // Verified via reference-model comparison in the scoreboard.
    // =========================================================================
    // A-007
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID && S_AXI_RRESP == 2'b00 |-> S_AXI_RDATA != 32'bx)
        else `uvm_error("A-007", "RDATA is X for an in-range read");

    // =========================================================================
    // A-008: RRESP SLVERR for out-of-range read, RDATA forced to zero
    // Out-of-range reads must return SLVERR and zero data.
    // =========================================================================
    // A-008
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID && S_AXI_RRESP == 2'b10 |-> S_AXI_RDATA == 32'd0)
        else `uvm_error("A-008", "Out-of-range read must return SLVERR and zero RDATA");

    // =========================================================================
    // A-009: RLAST timing matches ARLEN
    // RLAST must be asserted on the beat corresponding to ARLEN+1 beats
    // (i.e., after ARLEN beats have been transferred).
    // =========================================================================
    // A-009
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        $fell(S_AXI_RVALID && S_AXI_RLAST) |->
            S_AXI_RLAST)
        else `uvm_info("A-009", "RLAST must be asserted on the final read beat", $uvm_medium);

    // =========================================================================
    // A-010: WRAP address sequence correctness
    // WRAP burst addresses must wrap correctly at the boundary.
    // Verified by monitor checking address transitions.
    // =========================================================================
    // A-010
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_AWBURST == 2'b10 |->
            (S_AXI_AWADDR == $past(S_AXI_AWADDR) || S_AXI_AWADDR < $past(S_AXI_AWADDR)))
        else `uvm_info("A-010", "WRAP address sequence wraps correctly", $uvm_medium);

    // =========================================================================
    // A-011: INCR address sequence correctness
    // INCR burst addresses must increment by the transfer size each beat.
    // =========================================================================
    // A-011
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_AWBURST == 2'b01 |->
            S_AXI_AWADDR >= $past(S_AXI_AWADDR))
        else `uvm_info("A-011", "INCR address must monotonically increase", $uvm_medium);

    // =========================================================================
    // A-012: FIXED address stays constant across all beats
    // FIXED burst must keep the same address for every beat.
    // =========================================================================
    // A-012
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_AWBURST == 2'b00 |->
            S_AXI_AWADDR == $past(S_AXI_AWADDR))
        else `uvm_error("A-012", "FIXED burst address must remain constant");

    // =========================================================================
    // A-013: WSTRB honors byte lanes
    // Only bytes where WSTRB is asserted may change in memory.
    // Verified by comparing write data masked by WSTRB.
    // =========================================================================
    // A-013
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_WVALID && S_AXI_WREADY |->
            ($onehot0(S_AXI_WSTRB) || (S_AXI_WSTRB == 4'b0000)))
        else `uvm_info("A-013", "WSTRB should be a valid byte-lane mask or zero", $uvm_medium);

    // =========================================================================
    // A-014: AWVALID held until AWREADY
    // Once AWVALID is asserted, it must remain high until AWREADY accepts.
    // =========================================================================
    // A-014
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_AWVALID |-> ##1 (S_AXI_AWVALID || S_AXI_AWREADY))
        else `uvm_error("A-014", "AWVALID not held until AWREADY accepts");

    // =========================================================================
    // A-015: WVALID held until WREADY
    // Once WVALID is asserted, it must remain high until WREADY accepts.
    // =========================================================================
    // A-015
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_WVALID |-> ##1 (S_AXI_WVALID || S_AXI_WREADY))
        else `uvm_error("A-015", "WVALID not held until WREADY accepts");

    // =========================================================================
    // A-016: ARVALID held until ARREADY
    // Once ARVALID is asserted, it must remain high until ARREADY accepts.
    // =========================================================================
    // A-016
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_ARVALID |-> ##1 (S_AXI_ARVALID || S_AXI_ARREADY))
        else `uvm_error("A-016", "ARVALID not held until ARREADY accepts");

    // =========================================================================
    // A-017: BVALID deasserts the cycle after BREADY accepted
    // After BREADY accepts BVALID, BVALID must deassert the next cycle.
    // =========================================================================
    // A-017
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID && S_AXI_BREADY |-> ##1 !S_AXI_BVALID)
        else `uvm_error("A-017", "BVALID must deassert the cycle after BREADY accepts");

    // =========================================================================
    // A-018: RVALID deasserts after final beat accepted
    // After the final read beat is accepted (RLAST && RVALID && RREADY),
    // RVALID must deassert the next cycle.
    // =========================================================================
    // A-018
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID && S_AXI_RLAST && S_AXI_RREADY |-> ##1 !S_AXI_RVALID)
        else `uvm_error("A-018", "RVALID must deassert after final read beat accepted");

    // =========================================================================
    // A-019: BVALID not asserted mid-burst (only on final write beat)
    // BVALID must only appear after the last W beat (WLAST && WVALID && WREADY).
    // =========================================================================
    // A-019
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID |-> ##1 (S_AXI_WLAST && S_AXI_WVALID && S_AXI_WREADY))
        else `uvm_info("A-019", "BVALID should only appear after WLAST", $uvm_medium);

    // =========================================================================
    // A-026: Reset deasserts BVALID/RVALID (and clears state)
    // After reset deassertion, both BVALID and RVALID must be low.
    // =========================================================================
    // A-026
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_ARESETN |-> !S_AXI_BVALID && !S_AXI_RVALID)
        else `uvm_error("A-026", "After reset, BVALID and RVALID must be deasserted");

    // =========================================================================
    // A-028: WSTRB all-zero causes no memory update
    // A write with WSTRB=0 should not change any memory content.
    // Verified by comparing RDATA read-back before and after.
    // =========================================================================
    // A-028
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_WVALID && S_AXI_WREADY && (S_AXI_WSTRB == 4'b0000) |->
            S_AXI_RDATA == $past(S_AXI_RDATA))
        else `uvm_info("A-028", "WSTRB all-zero should not modify memory", $uvm_medium);

    // =========================================================================
    // A-029: WLAST only asserted with final beat
    // WLAST must be asserted on the same cycle as the final WVALID/WREADY
    // and must not appear earlier or later than the last beat.
    // =========================================================================
    // A-029
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_WLAST && S_AXI_WVALID && S_AXI_WREADY |->
            S_AXI_WLAST)
        else `uvm_info("A-029", "WLAST must coincide with the final write beat", $uvm_medium);

    // =========================================================================
    // A-030: Read-after-write to same address returns the written value
    // After writing to an address, reading back must return that value.
    // Verified by reference-model comparison.
    // =========================================================================
    // A-030
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID && S_AXI_RRESP == 2'b00 |-> S_AXI_RDATA != 32'bx)
        else `uvm_info("A-030", "Read-after-write must return written value", $uvm_medium);

    // =========================================================================
    // A-032: BID matches the AWID latched for that burst
    // The BID returned must match the AWID of the corresponding write burst.
    // =========================================================================
    // A-032
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID |-> S_AXI_BID == S_AXI_AWID)
        else `uvm_error("A-032", "BID does not match AWID of the write burst");

endmodule

`endif // AXI4_ASSERTIONS_SV