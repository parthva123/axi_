// axi4_tc040_wrap_burst_len16_test.sv
// File        : axi4_tc040_wrap_burst_len16_test.sv
// Description : Layer 2 test TC-040 - WRAP Burst Length 16
//               Verifies WRAP burst transaction with 16 beats (ax_len = 15).
//               Validates address wrapping calculation at the boundary (16 x 4 bytes = 64-byte boundary).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC040_WRAP_BURST_LEN16_TEST_SV
`define AXI4_TC040_WRAP_BURST_LEN16_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_wrap_len_seq.sv"

class axi4_tc040_wrap_burst_len16_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc040_wrap_burst_len16_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc040_wrap_burst_len16_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-040: WRAP Burst Length 16 (ax_len = 15)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC040", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute WRAP burst length 16 test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_wrap_len_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-040: Starting WRAP burst length 16 test", UVM_MEDIUM)

    seq = axi4_wrap_len_seq::type_id::create("seq");
    seq.target_len = 8'd15;          // 16 beats (ax_len = 15)
    seq.base_addr  = 32'h0000_0080;  // Aligned/wrapped to 64-byte boundary
    seq.trans_id   = 4'hA;
    seq.start(seqr);

    `uvm_info("TEST", "TC-040: WRAP burst length 16 test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC040_WRAP_BURST_LEN16_TEST_SV
