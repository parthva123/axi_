// axi4_seq_lib_pkg.sv
// File        : axi4_seq_lib_pkg.sv
// Description : UVM package for the AXI4 sequence library.
//               Contains all sequences: write, read, mem_sweep,
//               wlast_mismatch, master_not_ready, addr_map, plus
//               Layer 2 stress/corner sequences.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 2.0

`ifndef AXI4_SEQ_LIB_PKG_SV
`define AXI4_SEQ_LIB_PKG_SV

package axi4_seq_lib_pkg;

  `include "axi4_defines.svh"
  `include "axi4_typedefs.svh"
  `include "axi4_seq_item.sv"
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

endpackage

`endif // AXI4_SEQ_LIB_PKG_SV
