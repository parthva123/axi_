// axi4_test_pkg.sv
// File        : axi4_test_pkg.sv
// Description : UVM package for all AXI4 slave testbench tests.
//               Includes Layer 0 protocol tests (TC-001..TC-017),
//               Layer 1 memory sweep tests (TC-M001..TC-M200 via tc-018..tc-027),
//               Layer 2 corner/stress tests (TC-028..TC-041),
//               and the full regression test suite.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TEST_PKG_SV
`define AXI4_TEST_PKG_SV

package axi4_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Defines and typedefs
  `include "axi4_defines.svh"
  `include "axi4_typedefs.svh"
  `include "axi4_macros.svh"

  // Sequence item
  `include "axi4_seq_item.sv"

  // Agent components
  `include "axi4_agent_config.sv"
  `include "axi4_driver.sv"
  `include "axi4_sequencer.sv"
  `include "axi4_monitor.sv"
  `include "axi4_coverage.sv"
  `include "axi4_agent.sv"

  // Sequences
  `include "axi4_write_seq.sv"
  `include "axi4_read_seq.sv"
  `include "axi4_mem_sweep_seq.sv"
  `include "axi4_wlast_mismatch_seq.sv"
  `include "axi4_master_not_ready_seq.sv"
  `include "axi4_addr_map_seq.sv"
  `include "axi4_full_mem_write_seq.sv"
  `include "axi4_full_mem_read_seq.sv"
  `include "axi4_boundary_seq.sv"
  `include "axi4_adjacent_oor_seq.sv"
  `include "axi4_wstrb_zero_seq.sv"
  `include "axi4_byte_lane_seq.sv"
  `include "axi4_interleaved_rw_seq.sv"
  `include "axi4_reset_during_burst_seq.sv"
  `include "axi4_consecutive_oor_seq.sv"
  `include "axi4_wrap_len_seq.sv"
  `include "axi4_max_incr_seq.sv"

  // Environment components
  `include "axi4_env_config.sv"
  `include "axi4_ref_model.sv"
  `include "axi4_scoreboard.sv"
  `include "axi4_virtual_sequencer.sv"
  `include "axi4_env.sv"

  // Base test
  `include "axi4_base_test.sv"

  // Layer 0 tests (TC-001 through TC-017)
  `include "tc-001.sv"
  `include "tc-002.sv"
  `include "tc-003.sv"
  `include "tc-004.sv"
  `include "tc-005.sv"
  `include "tc-006.sv"
  `include "tc-007.sv"
  `include "tc-008.sv"
  `include "tc-009.sv"
  `include "tc-010.sv"
  `include "tc-011.sv"
  `include "tc-012.sv"
  `include "tc-013.sv"
  `include "tc-014.sv"
  `include "tc-015.sv"
  `include "tc-016.sv"
  `include "tc-017.sv"

  // Layer 1 tests (TC-018 through TC-027 - memory sweep and address map)
  `include "tc-018.sv"
  `include "tc-019.sv"
  `include "tc-020.sv"
  `include "tc-021.sv"
  `include "tc-022.sv"
  `include "tc-023.sv"
  `include "tc-024.sv"
  `include "tc-025.sv"
  `include "tc-026.sv"
  `include "tc-027.sv"

  // Layer 2 tests (TC-028 through TC-041 - stress and corner cases)
  `include "axi4_tc028_full_memory_write_sweep_test.sv"
  `include "axi4_tc029_full_memory_read_sweep_test.sv"
  `include "axi4_tc030_boundary_word0_test.sv"
  `include "axi4_tc031_boundary_word1023_test.sv"
  `include "axi4_tc032_adjacent_oor_test.sv"
  `include "axi4_tc033_wstrb_zero_test.sv"
  `include "axi4_tc034_every_byte_lane_test.sv"
  `include "axi4_tc035_interleaved_rw_test.sv"
  `include "axi4_tc036_reset_during_write_test.sv"
  `include "axi4_tc037_reset_during_read_test.sv"
  `include "axi4_tc038_consecutive_oor_test.sv"
  `include "axi4_tc039_wrap_burst_len2_test.sv"
  `include "axi4_tc040_wrap_burst_len16_test.sv"
  `include "axi4_tc041_incr_burst_max_len_test.sv"

  // Regression test
  `include "axi4_regression_test.sv"

endpackage

`endif // AXI4_TEST_PKG_SV
