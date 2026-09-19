// TC-027.sv
// File        : tc-027.sv
// Description : Layer 2 test - Concurrent read/write using virtual sequencer.
//               Runs concurrent R/W sequences across multiple regions.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef TC-027_SV
`define TC-027_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_write_seq.sv"
`include "axi4_read_seq.sv"
`include "axi4_virtual_sequencer.sv"

class tc_027 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_virtual_sequencer vseqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_027)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_027", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-027: Concurrent read/write", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get virtual sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_virtual_sequencer)::get(this, "", "vseqr", vseqr)) begin
      `uvm_info("TEST", "TC-027: virtual sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute concurrent read/write sequences
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-027: starting concurrent R/W sequences", UVM_MEDIUM)

    axi4_write_seq wseq;
    axi4_read_seq  rseq;

    wseq = axi4_write_seq::type_id::create("axi4_write_seq");
    rseq = axi4_read_seq::type_id::create("axi4_read_seq");

    // Fork concurrent write and read sequences
    fork
      begin
        wseq.start(vseqr.seqr);
      end
      begin
        rseq.start(vseqr.seqr);
      end
    join

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-027_SV