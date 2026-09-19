// TC-019.sv
// File        : tc-019.sv
// Description : Layer 0 test - Memory sweep large blocks.
//               Runs axi4_mem_sweep_seq sequence: Sweeps TC-M177..TC-M200
//               through large memory blocks with incremental addresses.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef TC-019_SV
`define TC-019_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_mem_sweep_seq.sv"

class tc_019 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_019)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_019", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-019: Memory sweep large blocks", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-019: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-019: starting sequence", UVM_MEDIUM)

    axi4_mem_sweep_seq seq;
    seq = axi4_mem_sweep_seq::type_id::create("axi4_mem_sweep_seq");
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-019_SV