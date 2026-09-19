// TC-041.sv
// File        : tc-041.sv
// Description : Layer 2 test - INCR Burst Maximum Length (255).
//               Runs axi4_max_incr_seq: Tests 256-beat INCR burst (ax_len=255),
//               the maximum AXI4 burst length, to stress beat counter and memory FSM.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-041_SV
`define TC-041_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_max_incr_seq.sv"

class tc_041 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_041)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_041", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-041: INCR Burst Maximum Length (255)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-041: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-041: starting sequence", UVM_MEDIUM)

    axi4_max_incr_seq seq;
    seq = axi4_max_incr_seq::type_id::create("axi4_max_incr_seq");
    seq.start_addr = 32'h0000_0000;
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-041_SV
