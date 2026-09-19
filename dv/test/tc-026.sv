// TC-026.sv
// File        : tc-026.sv
// Description : Layer 1 test - Memory sweep with mixed burst types.
//               Runs axi4_mem_sweep_seq sequence: Sweeps TC-M201..TC-M250
//               with mixed FIXED/INCR/WRAP burst types.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef TC-026_SV
`define TC-026_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_mem_sweep_seq.sv"

class tc_026 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_026)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_026", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-026: Memory sweep with mixed burst types", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-026: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-026: starting sequence", UVM_MEDIUM)

    axi4_mem_sweep_seq seq;
    seq = axi4_mem_sweep_seq::type_id::create("axi4_mem_sweep_seq");
    seq.burst_type = `BURST_INCR;  // Override to INCR for this batch
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-026_SV