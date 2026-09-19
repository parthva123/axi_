// TC-033.sv
// File        : tc-033.sv
// Description : Layer 2 test - WSTRB All-Zero Write.
//               Runs axi4_wstrb_zero_seq: Verifies writing with WSTRB=4'b0000 causes no memory modification.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-033_SV
`define TC-033_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_wstrb_zero_seq.sv"

class tc_033 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_033)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_033", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-033: WSTRB All-Zero Write", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-033: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-033: starting sequence", UVM_MEDIUM)

    axi4_wstrb_zero_seq seq;
    seq = axi4_wstrb_zero_seq::type_id::create("axi4_wstrb_zero_seq");
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-033_SV
