// axi4_tc038_consecutive_oor_test.sv
// File        : axi4_tc038_consecutive_oor_test.sv
// Description : Layer 2 test TC-038 - Consecutive Out-of-Range Bursts
//               Verifies that multiple consecutive out-of-range write and read
//               bursts all return SLVERR and do not corrupt memory or DUT state.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC038_CONSECUTIVE_OOR_TEST_SV
`define AXI4_TC038_CONSECUTIVE_OOR_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_consecutive_oor_seq.sv"

class axi4_tc038_consecutive_oor_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc038_consecutive_oor_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc038_consecutive_oor_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-038: Consecutive Out-of-Range Bursts", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC038", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute consecutive OOR test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_consecutive_oor_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-038: Starting consecutive out-of-range test", UVM_MEDIUM)

    seq = axi4_consecutive_oor_seq::type_id::create("seq");
    seq.num_oor_transactions = 20;
    seq.trans_id             = 4'h8;
    seq.start(seqr);

    `uvm_info("TEST", "TC-038: Consecutive out-of-range test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC038_CONSECUTIVE_OOR_TEST_SV
