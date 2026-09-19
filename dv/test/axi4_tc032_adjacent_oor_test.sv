// axi4_tc032_adjacent_oor_test.sv
// File        : axi4_tc032_adjacent_oor_test.sv
// Description : Layer 2 test TC-032 - Adjacent Out-of-Range Address
//               Verifies that addresses immediately adjacent to valid memory range
//               (0x1000, 0x1004, 0x80000000, 0xFFFFFFFC) return SLVERR on write/read
//               and do not modify memory.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC032_ADJACENT_OOR_TEST_SV
`define AXI4_TC032_ADJACENT_OOR_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_adjacent_oor_seq.sv"

class axi4_tc032_adjacent_oor_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc032_adjacent_oor_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc032_adjacent_oor_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-032: Adjacent Out-of-Range Address", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC032", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute adjacent out-of-range test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_adjacent_oor_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-032: Starting adjacent out-of-range test", UVM_MEDIUM)

    seq = axi4_adjacent_oor_seq::type_id::create("seq");
    seq.trans_id = 4'h2;
    seq.start(seqr);

    `uvm_info("TEST", "TC-032: Adjacent out-of-range test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC032_ADJACENT_OOR_TEST_SV
