// TC-038.sv
// File        : tc-038.sv
// Description : Layer 2 test - Consecutive Out-of-Range Bursts.
//               Runs axi4_consecutive_oor_seq: Issues multiple consecutive out-of-range
//               write and read bursts to verify SLVERR handling and memory protection.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-038_SV
`define TC-038_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_consecutive_oor_seq.sv"

class tc_038 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_038)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_038", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-038: Consecutive Out-of-Range Bursts", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-038: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-038: starting sequence", UVM_MEDIUM)

    axi4_consecutive_oor_seq seq;
    seq = axi4_consecutive_oor_seq::type_id::create("axi4_consecutive_oor_seq");
    seq.num_oor_transactions = 10;
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-038_SV
