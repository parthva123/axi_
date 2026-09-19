// axi4_env.sv
// File        : axi4_env.sv
// Description : UVM environment for the AXI4 slave testbench.
//               Combines agent, scoreboard, and reference model.
//               Connects driver/monitor analysis ports to scoreboard.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_ENV_SV
`define AXI4_ENV_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_env_config.sv"
`include "axi4_agent.sv"
`include "axi4_ref_model.sv"
`include "axi4_scoreboard.sv"
`include "axi4_virtual_sequencer.sv"

class axi4_env extends uvm_env;

  // -----------------------------------------------------------------------
  // Sub-components
  // -----------------------------------------------------------------------
  axi4_agent       agent;
  axi4_scoreboard  scoreboard;
  axi4_ref_model   ref_model;

  // -----------------------------------------------------------------------
  // Virtual sequencer reference (for cross-channel sequences)
  // -----------------------------------------------------------------------
  axi4_virtual_sequencer vseqr;

  // -----------------------------------------------------------------------
  // Config handle
  // -----------------------------------------------------------------------
  axi4_env_config cfg;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_env)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create sub-components
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get environment configuration
    if (!uvm_config_db#(axi4_env_config)::get(this, "", "cfg", cfg)) begin
      cfg = axi4_env_config::type_id::create("cfg");
      `uvm_info("ENV", "Using default env config", UVM_MEDIUM)
    end

    // Create agent
    agent = axi4_agent::type_id::create("agent", this);

    // Create reference model
    if (cfg.enable_ref_model) begin
      ref_model = axi4_ref_model::type_id::create("ref_model", this);
    end

    // Create scoreboard
    if (cfg.enable_scoreboard) begin
      scoreboard = axi4_scoreboard::type_id::create("scoreboard", this);
    end

    // Create virtual sequencer
    vseqr = axi4_virtual_sequencer::type_id::create("vseqr", this);

    `uvm_info("ENV", "axi4_env built", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: connect analysis ports
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect agent analysis port to scoreboard
    if (scoreboard != null && agent != null) begin
      agent.analysis_port.connect(scoreboard.analysis_export);
    end

    // Set virtual sequencer reference in config DB
    uvm_config_db#(axi4_virtual_sequencer)::set(this, "*.vseqr", "vseqr", vseqr);

    `uvm_info("ENV", "axi4_env connected", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // End of elaboration phase
  // -----------------------------------------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("ENV", "axi4_env end_of_elaboration", UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Report phase
  // -----------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info("ENV", "axi4_env report", UVM_LOW)
    super.report_phase(phase);
  endfunction

endclass

`endif // AXI4_ENV_SV