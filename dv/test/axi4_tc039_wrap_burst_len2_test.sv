// axi4_tc039_wrap_burst_len2_test.sv
// File        : axi4_tc039_wrap_burst_len2_test.sv
// Description : Layer 2 test TC-039 - WRAP Burst Length 2
//               Verifies WRAP burst transaction with 2 beats (ax_len = 1).
//               Validates address wrapping calculation at the boundary (2 x 4 bytes = 8-byte boundary).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC039_WRAP_BURST_LEN2_TEST_SV
`define AXI4_TC039_WRAP_BURST_LEN2_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_wrap_len_seq.sv"

class axi4_tc039_wrap_burst_len2_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc039_wrap_burst_len2_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc039_wrap_burst_len2_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-039: WRAP Burst Length 2 (ax_len = 1)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC039", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute WRAP burst length 2 test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_wrap_len_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-039: Starting WRAP burst length 2 test", UVM_MEDIUM)

    seq = axi4_wrap_len_seq::type_id::create("seq");
    seq.target_len = 8'd1;           // 2 beats (ax_len = 1)
    seq.base_addr  = 32'h0000_0044;  // Aligned/wrapped to 8-byte boundary
    seq.trans_id   = 4'h9;
    seq.start(seqr);

    `uvm_info("TEST", "TC-039: WRAP burst length 2 test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC039_WRAP_BURST_LEN2_TEST_SV
