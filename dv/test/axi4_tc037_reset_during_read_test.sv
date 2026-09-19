// axi4_tc037_reset_during_read_test.sv
// File        : axi4_tc037_reset_during_read_test.sv
// Description : Layer 2 test TC-037 - Reset During Active Read Burst
//               Verifies that asserting reset during an active read burst
//               cleanly aborts the read transaction, deasserts RVALID/ARREADY,
//               and allows subsequent transactions to proceed after reset deassertion.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC037_RESET_DURING_READ_TEST_SV
`define AXI4_TC037_RESET_DURING_READ_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_reset_during_burst_seq.sv"

class axi4_tc037_reset_during_read_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc037_reset_during_read_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc037_reset_during_read_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-037: Reset During Active Read Burst", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC037", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute reset during read burst test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_reset_during_burst_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-037: Starting reset during read burst test", UVM_MEDIUM)

    seq = axi4_reset_during_burst_seq::type_id::create("seq");
    seq.is_write   = 1'b0;
    seq.start_addr = 32'h00000100;
    seq.burst_len  = 8'd15;  // 16 beats
    seq.trans_id   = 4'h7;
    seq.start(seqr);

    `uvm_info("TEST", "TC-037: Reset during read burst test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC037_RESET_DURING_READ_TEST_SV
