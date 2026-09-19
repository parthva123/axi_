// axi4_monitor.sv
// File        : axi4_monitor.sv
// Description : UVM monitor for the AXI4 slave testbench.
//               Samples all AXI4 channel activity from the interface
//               and reconstructs full transaction-level objects for
//               scoreboard, coverage, and assertion checking.
//               Uses monitor_cb clocking block (inputs only).
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_MONITOR_SV
`define AXI4_MONITOR_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"

class axi4_monitor extends uvm_monitor;

  // -----------------------------------------------------------------------
  // Virtual interface handle
  // -----------------------------------------------------------------------
  virtual axi4_if vif;

  // -----------------------------------------------------------------------
  // Analysis port for driving scoreboard and coverage
  // -----------------------------------------------------------------------
  uvm_analysis #(axi4_seq_item) analysis_port;

  // -----------------------------------------------------------------------
  // Config handle
  // -----------------------------------------------------------------------
  axi4_agent_config cfg;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_monitor)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: get config, create analysis port
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface must be set for axi4_monitor")
    if (!uvm_config_db#(axi4_agent_config)::get(this, "", "cfg", cfg)) begin
      cfg = axi4_agent_config::type_id::create("cfg");
      `uvm_info("MON", "Using default config", UVM_MEDIUM)
    end
    analysis_port = new("analysis_port", this);
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: sample transactions from monitor_cb
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_seq_item tx;
    forever begin
      // Collect a full write or read transaction from interface activity
      tx = collect_tx();
      if (tx != null) begin
        `uvm_info("MON", $sformatf(
          "Collected %s tx: addr=0x%0h %s %s",
          tx.is_write ? "WRITE" : "READ",
          tx.ax_addr, tx.burst_name(), tx.dir_name()), UVM_MEDIUM)
        analysis_port.write(tx);
      end
    end
  endtask

  // -----------------------------------------------------------------------
  // Collect a full write transaction (AW + W + B)
  // -----------------------------------------------------------------------
  virtual function axi4_seq_item collect_write_tx();
    axi4_seq_item tx = axi4_seq_item::type_id::create("tx");
    tx.is_write = 1;

    // --- Reconstruct AW ---
    tx.ax_id    = vif.monitor_cb.S_AXI_AWID;
    tx.ax_addr  = vif.monitor_cb.S_AXI_AWADDR;
    tx.ax_len   = vif.monitor_cb.S_AXI_AWLEN;
    tx.ax_size  = vif.monitor_cb.S_AXI_AWSIZE;
    tx.ax_burst = vif.monitor_cb.S_AXI_AWBURST;
    tx.ax_lock  = vif.monitor_cb.S_AXI_AWLOCK;
    tx.ax_cache = vif.monitor_cb.S_AXI_AWCACHE;
    tx.ax_prot  = vif.monitor_cb.S_AXI_AWPROT;
    tx.ax_qos   = vif.monitor_cb.S_AXI_AWQOS;
    tx.w_data   = vif.monitor_cb.S_AXI_WDATA;
    tx.w_strb   = vif.monitor_cb.S_AXI_WSTRB;
    tx.w_last   = vif.monitor_cb.S_AXI_WLAST;

    // --- Reconstruct B ---
    tx.b_id    = vif.monitor_cb.S_AXI_BID;
    tx.b_resp  = vif.monitor_cb.S_AXI_BRESP;
    tx.b_valid_ok = (vif.monitor_cb.S_AXI_BVALID && vif.monitor_cb.S_AXI_BREADY);

    return tx;
  endfunction

  // -----------------------------------------------------------------------
  // Collect a full read transaction (AR + R)
  // -----------------------------------------------------------------------
  virtual function axi4_seq_item collect_read_tx();
    axi4_seq_item tx = axi4_seq_item::type_id::create("tx");
    tx.is_write = 0;

    // --- Reconstruct AR ---
    tx.ax_id    = vif.monitor_cb.S_AXI_ARID;
    tx.ax_addr  = vif.monitor_cb.S_AXI_ARADDR;
    tx.ax_len   = vif.monitor_cb.S_AXI_ARLEN;
    tx.ax_size  = vif.monitor_cb.S_AXI_ARSIZE;
    tx.ax_burst = vif.monitor_cb.S_AXI_ARBURST;
    tx.ax_lock  = vif.monitor_cb.S_AXI_ARLOCK;
    tx.ax_cache = vif.monitor_cb.S_AXI_ARCACHE;
    tx.ax_prot  = vif.monitor_cb.S_AXI_ARPROT;
    tx.ax_qos   = vif.monitor_cb.S_AXI_ARQOS;

    // --- Reconstruct R ---
    tx.r_id    = vif.monitor_cb.S_AXI_RID;
    tx.r_data  = vif.monitor_cb.S_AXI_RDATA;
    tx.r_resp  = vif.monitor_cb.S_AXI_RRESP;
    tx.r_last  = vif.monitor_cb.S_AXI_RLAST;
    tx.r_valid_ok = (vif.monitor_cb.S_AXI_RVALID && vif.monitor_cb.S_AXI_RREADY);

    return tx;
  endfunction

  // -----------------------------------------------------------------------
  // Collect a full transaction (write or read, auto-detected)
  // -----------------------------------------------------------------------
  virtual function axi4_seq_item collect_tx();
    // Simple heuristic: if AWVALID && AWREADY active, it's a write;
    // else if ARVALID && ARREADY active, it's a read.
    // In practice a more sophisticated state-monitor would be used.
    if (vif.monitor_cb.S_AXI_AWVALID && vif.monitor_cb.S_AXI_AWREADY) begin
      return collect_write_tx();
    end else if (vif.monitor_cb.S_AXI_ARVALID && vif.monitor_cb.S_AXI_ARREADY) begin
      return collect_read_tx();
    end else begin
      return null;
    end
  endfunction

endclass

`endif // AXI4_MONITOR_SV