// axi4_tc035_interleaved_rw_test.sv
// File        : axi4_tc035_interleaved_rw_test.sv
// Description : Layer 2 test TC-035 - Interleaved Read/Write Across Memory
//               Stresses independent write and read FSMs with alternating write
//               and read transactions across distributed memory addresses.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC035_INTERLEAVED_RW_TEST_SV
`define AXI4_TC035_INTERLEAVED_RW_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_interleaved_rw_seq.sv"

class axi4_tc035_interleaved_rw_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc035_interleaved_rw_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc035_interleaved_rw_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-035: Interleaved Read/Write Across Memory", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC035", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute interleaved R/W test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_interleaved_rw_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-035: Starting interleaved R/W test", UVM_MEDIUM)

    seq = axi4_interleaved_rw_seq::type_id::create("seq");
    seq.num_pairs = 32;
    seq.trans_id  = 4'h5;
    seq.start(seqr);

    `uvm_info("TEST", "TC-035: Interleaved R/W test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC035_INTERLEAVED_RW_TEST_SV
