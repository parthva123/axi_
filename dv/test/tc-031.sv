// TC-031.sv
// File        : tc-031.sv
// Description : Layer 2 test - Memory Boundary Word 1023 (address 0x0FFC).
//               Runs axi4_boundary_seq: Verifies read/write access to word 1023.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-031_SV
`define TC-031_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_boundary_seq.sv"

class tc_031 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_031)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_031", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-031: Memory Boundary Word 1023 (address 0x0FFC)", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-031: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-031: starting sequence", UVM_MEDIUM)

    axi4_boundary_seq seq;
    seq = axi4_boundary_seq::type_id::create("axi4_boundary_seq");
    seq.boundary_addr = 32'h0000_0FFC;  // Word 1023 (1023 * 4 = 0x0FFC)
    seq.write_data    = 32'h5A5A_A5A5;
    seq.start(seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-031_SV
