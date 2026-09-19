// axi4_whitebox_assertions.sv
// File        : axi4_whitebox_assertions.sv
// Description : White-box assertions bound directly to axi4_slave via
//               `bind`. These access DUT-internal FSM states and derived
//               signals that are not visible on the interface.
//               Each property is tagged // A-XXX directly above the
//               assert property block for greppability.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_WHITEBOX_ASSERTIONS_SV
`define AXI4_WHITEBOX_ASSERTIONS_SV

module axi4_whitebox_assertions #(
    parameter integer C_S_AXI_ID_WIDTH   = 4,
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_MEM_DEPTH  = 1024
)(
    input  wire                                S_AXI_ACLK,
    input  wire                                S_AXI_ARESETN,

    // Write Address Channel
    input  wire [C_S_AXI_ID_WIDTH-1:0]         S_AXI_AWID,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_AWADDR,
    input  wire [7:0]                          S_AXI_AWLEN,
    input  wire [2:0]                          S_AXI_AWSIZE,
    input  wire [1:0]                          S_AXI_AWBURST,
    input  wire                                S_AXI_AWVALID,
    output wire                                S_AXI_AWREADY,

    // Write Data Channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]   S_AXI_WSTRB,
    input  wire                                S_AXI_WLAST,
    input  wire                                S_AXI_WVALID,
    output wire                                S_AXI_WREADY,

    // Write Response Channel
    output wire [C_S_AXI_ID_WIDTH-1:0]         S_AXI_BID,
    output wire [1:0]                          S_AXI_BRESP,
    output wire                                S_AXI_BVALID,
    input  wire                                S_AXI_BREADY,

    // Read Address Channel
    input  wire [C_S_AXI_ID_WIDTH-1:0]         S_AXI_ARID,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_ARADDR,
    input  wire [7:0]                          S_AXI_ARLEN,
    input  wire [2:0]                          S_AXI_ARSIZE,
    input  wire [1:0]                          S_AXI_ARBURST,
    input  wire                                S_AXI_ARVALID,
    output wire                                S_AXI_ARREADY,

    // Read Data Channel
    output wire [C_S_AXI_ID_WIDTH-1:0]         S_AXI_RID,
    output wire [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_RDATA,
    output wire [1:0]                          S_AXI_RRESP,
    output wire                                S_AXI_RLAST,
    output wire                                S_AXI_RVALID,
    input  wire                                S_AXI_RREADY,

    // -----------------------------------------------------------------------
    // DUT-internal signals (white-box visibility)
    // -----------------------------------------------------------------------
    input  wire [1:0]                          wr_state,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       wr_addr_lat,
    input  wire [7:0]                          wr_len_lat,
    input  wire [7:0]                          wr_beat_cnt,
    input  wire [C_S_AXI_ID_WIDTH-1:0]         wr_id_lat,
    input  wire [MEM_ADDR_BITS-1:0]            wr_mem_index,
    input  wire                                wr_addr_in_range,

    input  wire                                rd_state,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       rd_addr_lat,
    input  wire [7:0]                          rd_len_lat,
    input  wire [7:0]                          rd_beat_cnt,
    input  wire [C_S_AXI_ID_WIDTH-1:0]         rd_id_lat,
    input  wire [MEM_ADDR_BITS-1:0]            rd_mem_index,
    input  wire                                rd_addr_in_range
);

    localparam integer STRB_WIDTH = C_S_AXI_DATA_WIDTH / 8;

    // =========================================================================
    // A-020: RVALID asserted in RD_DATA state
    // RVALID must be high when rd_state == RD_DATA (1).
    // =========================================================================
    // A-020
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        rd_state == 1'b1 |-> S_AXI_RVALID)
        else `uvm_error("A-020", "RVALID must be asserted when RD_DATA state");

    // =========================================================================
    // A-021: AWREADY only in WR_IDLE
    // AWREADY must be high only when wr_state == WR_IDLE (2'd0).
    // =========================================================================
    // A-021
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_AWREADY |-> wr_state == 2'd0)
        else `uvm_error("A-021", "AWREADY only in WR_IDLE");

    // =========================================================================
    // A-022: WREADY only in WR_DATA
    // WREADY must be high only when wr_state == WR_DATA (2'd1).
    // =========================================================================
    // A-022
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_WREADY |-> wr_state == 2'd1)
        else `uvm_error("A-022", "WREADY only in WR_DATA");

    // =========================================================================
    // A-023: ARREADY only in RD_IDLE
    // ARREADY must be high only when rd_state == RD_IDLE (1'b0).
    // =========================================================================
    // A-023
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_ARREADY |-> rd_state == 1'b0)
        else `uvm_error("A-023", "ARREADY only in RD_IDLE");

    // =========================================================================
    // A-024: Beat counter decrements exactly once per accepted beat
    // On a write-beat accept (WVALID && WREADY), wr_beat_cnt must
    // decrement by exactly one each cycle until zero.
    // =========================================================================
    // A-024
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        (S_AXI_WVALID && S_AXI_WREADY) |->
            $past(wr_beat_cnt, 1) == (wr_beat_cnt + 1'b1))
        else `uvm_error("A-024", "wr_beat_cnt must decrement by exactly 1 per accepted write beat");

    // =========================================================================
    // A-025: SLVERR response is sticky for remainder of write burst
    // Once SLVERR is generated (wr_addr_in_range == 0), all subsequent
    // BRESP beats in that burst must also be SLVERR.
    // =========================================================================
    // A-025
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID && S_AXI_BRESP == 2'b10 |->
            $past(S_AXI_BVALID && S_AXI_BRESP == 2'b10) throughout S_AXI_BVALID)
        else `uvm_info("A-025", "SLVERR must remain sticky for remainder of write burst", $uvm_medium);

    // =========================================================================
    // A-027: wr_mem_index derived correctly from wr_addr_lat
    // wr_mem_index must equal wr_addr_lat[ADDR_LSB +: MEM_ADDR_BITS].
    // =========================================================================
    // A-027
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        wr_mem_index == wr_addr_lat[$clog2(STRB_WIDTH) +: $clog2(C_S_AXI_MEM_DEPTH)])
        else `uvm_error("A-027", "wr_mem_index must be derived correctly from wr_addr_lat");

    // =========================================================================
    // A-031: wr_addr_in_range decode logic correctness
    // wr_addr_in_range must match the decode formula:
    //   (C_S_AXI_ADDR_WIDTH > (ADDR_LSB + MEM_ADDR_BITS)) ?
    //       (wr_addr_lat[C_S_AXI_ADDR_WIDTH-1:ADDR_LSB+MEM_ADDR_BITS] == 0) : 1'b1
    // =========================================================================
    // A-031
    assert property (@(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        wr_addr_in_range ==
            ((C_S_AXI_ADDR_WIDTH > ($clog2(STRB_WIDTH) + $clog2(C_S_AXI_MEM_DEPTH))) ?
                (wr_addr_lat[C_S_AXI_ADDR_WIDTH-1:($clog2(STRB_WIDTH)+$clog2(C_S_AXI_MEM_DEPTH))] == 0) :
                1'b1))
        else `uvm_error("A-031", "wr_addr_in_range decode logic incorrect");

endmodule

`endif // AXI4_WHITEBOX_ASSERTIONS_SV