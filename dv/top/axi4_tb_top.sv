// axi4_tb_top.sv
// File        : axi4_tb_top.sv
// Description : Top-level testbench module for AXI4 slave verification.
//               Instantiates DUT, interface, clock/reset generation,
//               binds assertion modules, and launches UVM test.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`timescale 1ns/1ps

module axi4_tb_top;

  // -----------------------------------------------------------------------
  // Import UVM package and test package
  // -----------------------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // -----------------------------------------------------------------------
  // Timing parameters (all in nanoseconds)
  // -----------------------------------------------------------------------
  parameter real CLK_PERIOD = 10.0;           // 100 MHz clock
  parameter int  RESET_CYCLES = 20;           // Reset duration in clocks
  parameter int  SIM_TIMEOUT_NS = 100_000_000; // 100ms simulation timeout

  // -----------------------------------------------------------------------
  // DUT parameters (must match axi4_slave.v and axi4_defines.svh)
  // -----------------------------------------------------------------------
  parameter C_S_AXI_ID_WIDTH   = 4;
  parameter C_S_AXI_ADDR_WIDTH = 32;
  parameter C_S_AXI_DATA_WIDTH = 32;
  parameter C_S_AXI_MEM_DEPTH  = 1024;

  // -----------------------------------------------------------------------
  // Clock and reset signals
  // -----------------------------------------------------------------------
  logic aclk;
  logic aresetn;

  // -----------------------------------------------------------------------
  // Interface instantiation
  // -----------------------------------------------------------------------
  axi4_if vif (
    .S_AXI_ACLK   (aclk),
    .S_AXI_ARESETN(aresetn)
  );

  // -----------------------------------------------------------------------
  // DUT instantiation
  // NOTE: Adjust module name if your DUT uses different name
  // -----------------------------------------------------------------------
  axi4_slave #(
    .C_S_AXI_ID_WIDTH   (C_S_AXI_ID_WIDTH),
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_MEM_DEPTH  (C_S_AXI_MEM_DEPTH)
  ) dut (
    // Clock and Reset
    .S_AXI_ACLK    (vif.S_AXI_ACLK),
    .S_AXI_ARESETN (vif.S_AXI_ARESETN),

    // Write Address Channel
    .S_AXI_AWID    (vif.S_AXI_AWID),
    .S_AXI_AWADDR  (vif.S_AXI_AWADDR),
    .S_AXI_AWLEN   (vif.S_AXI_AWLEN),
    .S_AXI_AWSIZE  (vif.S_AXI_AWSIZE),
    .S_AXI_AWBURST (vif.S_AXI_AWBURST),
    .S_AXI_AWLOCK  (vif.S_AXI_AWLOCK),
    .S_AXI_AWCACHE (vif.S_AXI_AWCACHE),
    .S_AXI_AWPROT  (vif.S_AXI_AWPROT),
    .S_AXI_AWQOS   (vif.S_AXI_AWQOS),
    .S_AXI_AWVALID (vif.S_AXI_AWVALID),
    .S_AXI_AWREADY (vif.S_AXI_AWREADY),

    // Write Data Channel
    .S_AXI_WDATA   (vif.S_AXI_WDATA),
    .S_AXI_WSTRB   (vif.S_AXI_WSTRB),
    .S_AXI_WLAST   (vif.S_AXI_WLAST),
    .S_AXI_WVALID  (vif.S_AXI_WVALID),
    .S_AXI_WREADY  (vif.S_AXI_WREADY),

    // Write Response Channel
    .S_AXI_BID     (vif.S_AXI_BID),
    .S_AXI_BRESP   (vif.S_AXI_BRESP),
    .S_AXI_BVALID  (vif.S_AXI_BVALID),
    .S_AXI_BREADY  (vif.S_AXI_BREADY),

    // Read Address Channel
    .S_AXI_ARID    (vif.S_AXI_ARID),
    .S_AXI_ARADDR  (vif.S_AXI_ARADDR),
    .S_AXI_ARLEN   (vif.S_AXI_ARLEN),
    .S_AXI_ARSIZE  (vif.S_AXI_ARSIZE),
    .S_AXI_ARBURST (vif.S_AXI_ARBURST),
    .S_AXI_ARLOCK  (vif.S_AXI_ARLOCK),
    .S_AXI_ARCACHE (vif.S_AXI_ARCACHE),
    .S_AXI_ARPROT  (vif.S_AXI_ARPROT),
    .S_AXI_ARQOS   (vif.S_AXI_ARQOS),
    .S_AXI_ARVALID (vif.S_AXI_ARVALID),
    .S_AXI_ARREADY (vif.S_AXI_ARREADY),

    // Read Data Channel
    .S_AXI_RID     (vif.S_AXI_RID),
    .S_AXI_RDATA   (vif.S_AXI_RDATA),
    .S_AXI_RRESP   (vif.S_AXI_RRESP),
    .S_AXI_RLAST   (vif.S_AXI_RLAST),
    .S_AXI_RVALID  (vif.S_AXI_RVALID),
    .S_AXI_RREADY  (vif.S_AXI_RREADY)
  );

  // -----------------------------------------------------------------------
  // Bind assertion modules
  // -----------------------------------------------------------------------
  // Black-box assertions (interface-level signals only)
  bind axi4_if axi4_assertions axi4_assertions_inst (
    .aclk   (S_AXI_ACLK),
    .aresetn(S_AXI_ARESETN),
    .vif    (axi4_if)
  );

  // White-box assertions (internal DUT signals via hierarchical reference)
  bind axi4_slave axi4_whitebox_assertions axi4_whitebox_assertions_inst (
    .aclk   (S_AXI_ACLK),
    .aresetn(S_AXI_ARESETN),
    // Internal signals passed from DUT
    .wr_state        (/* connect to DUT internal state */),
    .rd_state        (/* connect to DUT internal state */),
    .wr_addr_in_range(/* connect to DUT internal signal */),
    .wr_mem_index    (/* connect to DUT internal signal */)
  );

  // -----------------------------------------------------------------------
  // Clock generation
  // -----------------------------------------------------------------------
  initial begin
    aclk = 1'b0;
    forever #(CLK_PERIOD/2.0) aclk = ~aclk;
  end

  // -----------------------------------------------------------------------
  // Reset generation
  // -----------------------------------------------------------------------
  initial begin
    aresetn = 1'b0;
    repeat(RESET_CYCLES) @(posedge aclk);
    aresetn = 1'b1;
    $display("[TB_TOP] Reset deasserted at time %0t", $time);
  end

  // -----------------------------------------------------------------------
  // UVM configuration and test launch
  // -----------------------------------------------------------------------
  initial begin
    // Set interface in config DB for all components
    uvm_config_db#(virtual axi4_if)::set(null, "*", "vif", vif);

    // Optional: Set test timeout
    uvm_config_db#(int)::set(null, "*", "timeout_ns", SIM_TIMEOUT_NS);

    // Optional: Set verbosity level
    // uvm_config_db#(int)::set(null, "*", "recording_detail", UVM_FULL);

    // Print testbench banner
    $display("========================================");
    $display("  AXI4 Slave UVM Testbench");
    $display("  Clock Period: %0.2f ns", CLK_PERIOD);
    $display("  Memory Depth: %0d words", C_S_AXI_MEM_DEPTH);
    $display("  Data Width:   %0d bits", C_S_AXI_DATA_WIDTH);
    $display("========================================");

    // Run the test specified via +UVM_TESTNAME
    run_test();
  end

  // -----------------------------------------------------------------------
  // Simulation timeout watchdog
  // -----------------------------------------------------------------------
  initial begin
    #SIM_TIMEOUT_NS;
    $display("[TB_TOP] ERROR: Simulation timeout at %0t ns", $time);
    $finish;
  end

  // -----------------------------------------------------------------------
  // Waveform dump (optional, controlled by plusargs)
  // -----------------------------------------------------------------------
  initial begin
    if ($test$plusargs("DUMP_WAVES")) begin
      $dumpfile("axi4_slave_tb.vcd");
      $dumpvars(0, axi4_tb_top);
      $display("[TB_TOP] Waveform dump enabled: axi4_slave_tb.vcd");
    end
  end

  // -----------------------------------------------------------------------
  // Coverage collection (optional, controlled by plusargs)
  // -----------------------------------------------------------------------
  initial begin
    if ($test$plusargs("COVERAGE")) begin
      $display("[TB_TOP] Coverage collection enabled");
      // Simulator-specific coverage commands would go here
    end
  end

  // -----------------------------------------------------------------------
  // Final statistics
  // -----------------------------------------------------------------------
  final begin
    $display("========================================");
    $display("  Simulation ended at time: %0t", $time);
    $display("========================================");
  end

endmodule
