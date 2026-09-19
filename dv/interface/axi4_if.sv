// axi4_if.sv
// File        : axi4_if.sv
// Description : AXI4 master-slave interface connecting the UVM agent to
//               the DUT. Contains separate clocking blocks for the driver
//               and monitor with explicit input/output skew, plus modports.
//               Black-box assertions bind to this interface.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_IF_SV
`define AXI4_IF_SV

interface axi4_if #(
    parameter integer C_S_AXI_ID_WIDTH   = `C_S_AXI_ID_WIDTH,
    parameter integer C_S_AXI_ADDR_WIDTH = `C_S_AXI_ADDR_WIDTH,
    parameter integer C_S_AXI_DATA_WIDTH = `C_S_AXI_DATA_WIDTH,
    parameter integer C_S_AXI_MEM_DEPTH  = `C_S_AXI_MEM_DEPTH
);

  // -----------------------------------------------------------------------
  // Local derived parameters
  // -----------------------------------------------------------------------
  localparam integer STRB_WIDTH = C_S_AXI_DATA_WIDTH / 8;
  localparam integer ADDR_LSB   = $clog2(STRB_WIDTH);

  // -----------------------------------------------------------------------
  // Clock and reset
  // -----------------------------------------------------------------------
  logic S_AXI_ACLK;
  logic S_AXI_ARESETN;

  // -----------------------------------------------------------------------
  // Write Address Channel (AW)
  // -----------------------------------------------------------------------
  logic [C_S_AXI_ID_WIDTH-1:0]   S_AXI_AWID;
  logic [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;
  logic [7:0]                    S_AXI_AWLEN;
  logic [2:0]                    S_AXI_AWSIZE;
  logic [1:0]                    S_AXI_AWBURST;
  logic                          S_AXI_AWLOCK;
  logic [3:0]                    S_AXI_AWCACHE;
  logic [2:0]                    S_AXI_AWPROT;
  logic [3:0]                    S_AXI_AWQOS;
  logic                          S_AXI_AWVALID;
  logic                          S_AXI_AWREADY;

  // -----------------------------------------------------------------------
  // Write Data Channel (W)
  // -----------------------------------------------------------------------
  logic [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;
  logic [STRB_WIDTH-1:0]         S_AXI_WSTRB;
  logic                          S_AXI_WLAST;
  logic                          S_AXI_WVALID;
  logic                          S_AXI_WREADY;

  // -----------------------------------------------------------------------
  // Write Response Channel (B)
  // -----------------------------------------------------------------------
  logic [C_S_AXI_ID_WIDTH-1:0]   S_AXI_BID;
  logic [1:0]                    S_AXI_BRESP;
  logic                          S_AXI_BVALID;
  logic                          S_AXI_BREADY;

  // -----------------------------------------------------------------------
  // Read Address Channel (AR)
  // -----------------------------------------------------------------------
  logic [C_S_AXI_ID_WIDTH-1:0]   S_AXI_ARID;
  logic [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;
  logic [7:0]                    S_AXI_ARLEN;
  logic [2:0]                    S_AXI_ARSIZE;
  logic [1:0]                    S_AXI_ARBURST;
  logic                          S_AXI_ARLOCK;
  logic [3:0]                    S_AXI_ARCACHE;
  logic [2:0]                    S_AXI_ARPROT;
  logic [3:0]                    S_AXI_ARQOS;
  logic                          S_AXI_ARVALID;
  logic                          S_AXI_ARREADY;

  // -----------------------------------------------------------------------
  // Read Data Channel (R)
  // -----------------------------------------------------------------------
  logic [C_S_AXI_ID_WIDTH-1:0]   S_AXI_RID;
  logic [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
  logic [1:0]                    S_AXI_RRESP;
  logic                          S_AXI_RLAST;
  logic                          S_AXI_RVALID;
  logic                          S_AXI_RREADY;

  // -----------------------------------------------------------------------
  // Driver clocking block (master drives AW/W/AR, samples B/R)
  // -----------------------------------------------------------------------
  clocking driver_cb @(posedge S_AXI_ACLK);
    default input #1step output #0;
    output S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN, S_AXI_AWSIZE, S_AXI_AWBURST;
    output S_AXI_AWLOCK, S_AXI_AWCACHE, S_AXI_AWPROT, S_AXI_AWQOS, S_AXI_AWVALID;
    output S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST, S_AXI_WVALID;
    output S_AXI_BREADY;
    output S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST;
    output S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, S_AXI_ARQOS, S_AXI_ARVALID;
    output S_AXI_RREADY;
    input  S_AXI_AWREADY, S_AXI_WREADY, S_AXI_BID, S_AXI_BRESP, S_AXI_BVALID;
    input  S_AXI_ARREADY, S_AXI_RID, S_AXI_RDATA, S_AXI_RRESP, S_AXI_RLAST, S_AXI_RVALID;
  endclocking

  // -----------------------------------------------------------------------
  // Monitor clocking block (samples everything, drives nothing)
  // -----------------------------------------------------------------------
  clocking monitor_cb @(posedge S_AXI_ACLK);
    default input #1step;
    input S_AXI_ACLK, S_AXI_ARESETN;
    input S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN, S_AXI_AWSIZE, S_AXI_AWBURST;
    input S_AXI_AWLOCK, S_AXI_AWCACHE, S_AXI_AWPROT, S_AXI_AWQOS, S_AXI_AWVALID;
    input S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST, S_AXI_WVALID;
    input S_AXI_BID, S_AXI_BRESP, S_AXI_BVALID, S_AXI_BREADY;
    input S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST;
    input S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, S_AXI_ARQOS, S_AXI_ARVALID;
    input S_AXI_RID, S_AXI_RDATA, S_AXI_RRESP, S_AXI_RLAST, S_AXI_RVALID, S_AXI_RREADY;
    input S_AXI_AWREADY, S_AXI_WREADY, S_AXI_ARREADY;
  endclocking

  // -----------------------------------------------------------------------
  // Modports
  // -----------------------------------------------------------------------
  modport driver_mp (
    clocking driver_cb,
    input S_AXI_ACLK, S_AXI_ARESETN
  );

  modport monitor_mp (
    clocking monitor_cb,
    input S_AXI_ACLK, S_AXI_ARESETN
  );

  modport dut_mp (
    input S_AXI_ACLK, S_AXI_ARESETN,
    input S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN, S_AXI_AWSIZE, S_AXI_AWBURST,
    input S_AXI_AWLOCK, S_AXI_AWCACHE, S_AXI_AWPROT, S_AXI_AWQOS, S_AXI_AWVALID,
    output S_AXI_AWREADY,
    input S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST, S_AXI_WVALID,
    output S_AXI_WREADY,
    output S_AXI_BID, S_AXI_BRESP, S_AXI_BVALID,
    input S_AXI_BREADY,
    input S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST,
    input S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, S_AXI_ARQOS, S_AXI_ARVALID,
    output S_AXI_ARREADY,
    output S_AXI_RID, S_AXI_RDATA, S_AXI_RRESP, S_AXI_RLAST, S_AXI_RVALID,
    input S_AXI_RREADY
  );

  // -----------------------------------------------------------------------
  // Assertions bind to this interface
  // -----------------------------------------------------------------------
  // Black-box assertions (A-001..A-032, excluding white-box subset)
  // bound to the interface-level signals only.
  bind axi4_if axi4_assertions axi4_assertions_i (.*);

  // White-box assertions (A-020,A-021,A-022,A-023,A-024,A-025,A-027,A-031)
  // are bound to the DUT in tb_top via axi4_whitebox_assertions_i,
  // using hierarchical visibility into axi4_slave internal signals.
  // (No direct bind here for white-box; see tb_top.)

endinterface

`endif // AXI4_IF_SV