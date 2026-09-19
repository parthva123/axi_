// axi4_agent_config.sv
// File        : axi4_agent_config.sv
// Description : Configuration class for the AXI4 agent.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_AGENT_CONFIG_SV
`define AXI4_AGENT_CONFIG_SV

class axi4_agent_config extends uvm_object;

  // -----------------------------------------------------------------------
  // Agent role: master (drives) or monitor-only
  // -----------------------------------------------------------------------
  bit is_active = 1'b1;

  // -----------------------------------------------------------------------
  // Clock period and timing knobs (in clock cycles)
  // -----------------------------------------------------------------------
  int unsigned timeout_cycles = `TC_BURST_TIMEOUT;

  // -----------------------------------------------------------------------
  // Driver knobs
  // -----------------------------------------------------------------------
  bit withhold_bready = 1'b0;  // TC-014: withhold BREADY
  bit withhold_rready = 1'b0;  // TC-015: withhold RREADY

  // -----------------------------------------------------------------------
  // Monitor knobs
  // -----------------------------------------------------------------------
  bit enable_coverage = 1'b1;

  // -----------------------------------------------------------------------
  // UVM factory and field automation
  // -----------------------------------------------------------------------
  `uvm_object_utils_begin(axi4_agent_config)
    `uvm_field_int(is_active,          UVM_DEFAULT)
    `uvm_field_int(timeout_cycles,     UVM_DEFAULT)
    `uvm_field_int(withhold_bready,    UVM_DEFAULT)
    `uvm_field_int(withhold_rready,    UVM_DEFAULT)
    `uvm_field_int(enable_coverage,    UVM_DEFAULT)
  `uvm_object_utils_end

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_agent_config");
    super.new(name);
  endfunction

endclass

`endif // AXI4_AGENT_CONFIG_SV