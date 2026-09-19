// TC-029.sv
// File        : tc-029.sv
// Description : Layer 2 test - Full Memory Read Sweep (128 bursts of 8 words).
//               Runs axi4_full_mem_read_seq: Reads all 1024 words from the memory array.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-029_SV
`define TC-029_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_full_mem_read_seq.sv"

class tc_029 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_029)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_029", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-029: Full Memory Read Sweep (128 bursts of 8 words)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-029: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-029: starting sequence", UVM_MEDIUM)

    axi4_full_mem_read_seq seq;
    seq = axi4_full_mem_read_seq::type_id::create("axi4_full_mem_read_seq");
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-029_SV
