// TC-032.sv
// File        : tc-032.sv
// Description : Layer 2 test - Adjacent Out-of-Range Address.
//               Runs axi4_adjacent_oor_seq: Verifies SLVERR response for addresses
//               adjacent to valid memory boundaries (just above 0x0FFF).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-032_SV
`define TC-032_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_adjacent_oor_seq.sv"

class tc_032 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_032)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_032", uvm_component parent);
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
      `uvm_info("TEST", "TC-032: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-032: starting sequence", UVM_MEDIUM)

    axi4_adjacent_oor_seq seq;
    seq = axi4_adjacent_oor_seq::type_id::create("axi4_adjacent_oor_seq");
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-032_SV
