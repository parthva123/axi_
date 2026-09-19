// axi4_tc041_incr_burst_max_len_test.sv
// File        : axi4_tc041_incr_burst_max_len_test.sv
// Description : Layer 2 test TC-041 - INCR Burst Maximum Length (255)
//               Verifies maximum AXI4 burst length of 256 beats (ax_len = 255).
//               Tests slave internal beat counter, throughput, and long burst stability.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC041_INCR_BURST_MAX_LEN_TEST_SV
`define AXI4_TC041_INCR_BURST_MAX_LEN_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_max_incr_seq.sv"

class axi4_tc041_incr_burst_max_len_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc041_incr_burst_max_len_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc041_incr_burst_max_len_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-041: INCR Burst Maximum Length (ax_len = 255, 256 beats)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC041", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute max length INCR burst test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_max_incr_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-041: Starting max length INCR burst test", UVM_MEDIUM)

    seq = axi4_max_incr_seq::type_id::create("seq");
    seq.start_addr = 32'h0000_0000;
    seq.trans_id   = 4'hB;
    seq.start(seqr);

    `uvm_info("TEST", "TC-041: Max length INCR burst test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC041_INCR_BURST_MAX_LEN_TEST_SV
