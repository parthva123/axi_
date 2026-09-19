// TC-040.sv
// File        : tc-040.sv
// Description : Layer 2 test - WRAP Burst Length 16.
//               Runs axi4_wrap_len_seq: Tests 16-beat WRAP burst (ax_len=15)
//               with proper address wrapping at boundary.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-040_SV
`define TC-040_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_wrap_len_seq.sv"

class tc_040 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_040)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_040", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-040: WRAP Burst Length 16", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-040: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-040: starting sequence", UVM_MEDIUM)

    axi4_wrap_len_seq seq;
    seq = axi4_wrap_len_seq::type_id::create("axi4_wrap_len_seq");
    seq.target_len = 8'd15;  // Length 16 (ax_len = 15 means 16 beats)
    seq.base_addr = 32'h0000_0040;
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-040_SV
