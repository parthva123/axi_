// axi4_agent.sv
// File        : axi4_agent.sv
// Description : UVM agent for the AXI4 slave testbench.
//               Combines driver, sequencer, monitor, and coverage collector.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_AGENT_SV
`define AXI4_AGENT_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_agent_config.sv"
`include "axi4_seq_item.sv"
`include "axi4_sequencer.sv"
`include "axi4_driver.sv"
`include "axi4_monitor.sv"
`include "axi4_coverage.sv"

class axi4_agent extends uvm_agent;

  // -----------------------------------------------------------------------
  // Sub-components
  // -----------------------------------------------------------------------
  axi4_sequencer seqr;
  axi4_driver drv;
  axi4_monitor mon;
  axi4_coverage cov;

  // -----------------------------------------------------------------------
  // Virtual interface handle
  // -----------------------------------------------------------------------
  virtual axi4_if vif;

  // -----------------------------------------------------------------------
  // Agent-level analysis port for external observers
  // -----------------------------------------------------------------------
  uvm_analysis_port #(axi4_seq_item) analysis_port;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_agent)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create sub-components
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    axi4_agent_config cfg;

    super.build_phase(phase);

    // Get agent configuration
    if (!uvm_config_db#(axi4_agent_config)::get(this, "", "cfg", cfg)) begin
      cfg = axi4_agent_config::type_id::create("cfg");
      `uvm_info("AGT", "Using default config", UVM_MEDIUM)
    end

    // Create driver and sequencer if agent is active
    if (cfg.is_active) begin
      drv = axi4_driver::type_id::create("drv", this);
      seqr = axi4_sequencer::type_id::create("seqr", this);
    end

    // Monitor and coverage are always present
    mon = axi4_monitor::type_id::create("mon", this);
    cov = axi4_coverage::type_id::create("cov", this);

    // Set configuration on sub-components
    if (drv != null) begin
      uvm_config_db#(axi4_agent_config)::set(this, "drv", "cfg", cfg);
      uvm_config_db#(axi4_agent_config)::set(this, "seqr", "cfg", cfg);
      uvm_config_db#(virtual axi4_if)::set(this, "drv", "vif", vif);
    end

    uvm_config_db#(axi4_agent_config)::set(this, "mon", "cfg", cfg);
    uvm_config_db#(virtual axi4_if)::set(this, "mon", "vif", vif);
    uvm_config_db#(axi4_agent_config)::set(this, "cov", "cfg", cfg);

    // Create agent-level analysis port
    analysis_port = new("analysis_port", this);

    `uvm_info("AGT", "axi4_agent built", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: connect analysis ports
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect monitor and driver analysis ports to agent analysis port
    mon.analysis_port.connect(analysis_port.analysis_export);

    if (drv != null) begin
      drv.analysis_port.connect(analysis_port.analysis_export);
    end

    // Connect monitor analysis port to coverage collector
    mon.analysis_port.connect(cov.coverage_port);

    `uvm_info("AGT", "axi4_agent connected", UVM_MEDIUM)
  endfunction

endclass

`endif // AXI4_AGENT_SV