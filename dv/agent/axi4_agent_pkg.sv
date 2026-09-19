// axi4_agent_pkg.sv
// File        : axi4_agent_pkg.sv
// Description : UVM package for the AXI4 agent.
//               Contains agent, driver, sequencer, monitor, coverage, config, and seq_item.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_AGENT_PKG_SV
`define AXI4_AGENT_PKG_SV

package axi4_agent_pkg;

  `include "axi4_defines.svh"
  `include "axi4_typedefs.svh"
  `include "axi4_seq_item.sv"
  `include "axi4_agent_config.sv"
  `include "axi4_sequencer.sv"
  `include "axi4_driver.sv"
  `include "axi4_monitor.sv"
  `include "axi4_coverage.sv"
  `include "axi4_agent.sv"

endpackage

`endif // AXI4_AGENT_PKG_SV