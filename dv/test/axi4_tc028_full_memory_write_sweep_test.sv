// axi4_tc028_full_memory_write_sweep_test.sv
// File        : axi4_tc028_full_memory_write_sweep_test.sv
// Description : Layer 2 test TC-028 - Full Memory Write Sweep
//               Tests complete memory write sweep using 128 bursts of 8 words each.
//               Covers all 1024 words (128 x 8 = 1024) with INCR burst type.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC028_FULL_MEMORY_WRITE_SWEEP_TEST_SV
`define AXI4_TC028_FULL_MEMORY_WRITE_SWEEP_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_full_mem_write_seq.sv"

class axi4_tc028_full_memory_write_sweep_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc028_full_memory_write_sweep_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc028_full_memory_write_sweep_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-028: Full Memory Write Sweep (128 bursts x 8 words)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC028", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute full memory write sweep
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_full_mem_write_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-028: Starting full memory write sweep", UVM_MEDIUM)

    seq = axi4_full_mem_write_seq::type_id::create("seq");
    seq.trans_id = 4'h0;
    seq.data_pattern_seed = 32'hDEAD_BEEF;
    seq.start(seqr);

    `uvm_info("TEST", "TC-028: Full memory write sweep complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC028_FULL_MEMORY_WRITE_SWEEP_TEST_SV
