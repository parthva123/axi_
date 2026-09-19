// axi4_env_config.sv
// File        : axi4_env_config.sv
// Description : Configuration class for the AXI4 environment.
//               Holds agent config + ref_model + scoreboard knobs.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_ENV_CONFIG_SV
`define AXI4_ENV_CONFIG_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_agent_config.sv"

class axi4_env_config extends uvm_object;

  // -----------------------------------------------------------------------
  // Agent configuration
  // -----------------------------------------------------------------------
  axi4_agent_config agent_cfg;

  // -----------------------------------------------------------------------
  // Environment knobs
  // -----------------------------------------------------------------------
  bit is_active = 1'b1;
  bit enable_coverage = 1'b1;
  bit enable_scoreboard = 1'b1;
  bit enable_ref_model = 1'b1;

  // -----------------------------------------------------------------------
  // Timing knobs (in clock cycles)
  // -----------------------------------------------------------------------
  int unsigned timeout_cycles = `TC_BURST_TIMEOUT;

  // -----------------------------------------------------------------------
  // Driver knobs
  // -----------------------------------------------------------------------
  bit withhold_bready = 1'b0;  // TC-014
  bit withhold_rready = 1'b0;  // TC-015

  // -----------------------------------------------------------------------
  // UVM factory and field automation
  // -----------------------------------------------------------------------
  `uvm_object_utils_begin(axi4_env_config)
    `uvm_field_object(agent_cfg,         UVM_DEFAULT)
    `uvm_field_int(is_active,            UVM_DEFAULT)
    `uvm_field_int(enable_coverage,      UVM_DEFAULT)
    `uvm_field_int(enable_scoreboard,    UVM_DEFAULT)
    `uvm_field_int(enable_ref_model,     UVM_DEFAULT)
    `uvm_field_int(timeout_cycles,       UVM_DEFAULT)
    `uvm_field_int(withhold_bready,     UVM_DEFAULT)
    `uvm_field_int(withhold_rready,     UVM_DEFAULT)
  `uvm_object_utils_end

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_env_config");
    super.new(name);
    agent_cfg = axi4_agent_config::type_id::create("agent_cfg");
  endfunction

endclass

`endif // AXI4_ENV_CONFIG_SV