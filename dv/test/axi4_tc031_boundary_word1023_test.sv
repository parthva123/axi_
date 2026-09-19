// axi4_tc031_boundary_word1023_test.sv
// File        : axi4_tc031_boundary_word1023_test.sv
// Description : Layer 2 test TC-031 - Memory Boundary Word 1023 (address 0x0FFC)
//               Verifies read and write operations at the highest valid memory boundary.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC031_BOUNDARY_WORD1023_TEST_SV
`define AXI4_TC031_BOUNDARY_WORD1023_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_boundary_seq.sv"

class axi4_tc031_boundary_word1023_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc031_boundary_word1023_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc031_boundary_word1023_test", uvm_component parent);
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
      `uvm_fatal("TC031", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute Word 1023 boundary test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_boundary_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-031: Starting Word 1023 boundary test", UVM_MEDIUM)

    seq = axi4_boundary_seq::type_id::create("seq");
    seq.boundary_addr = 32'h00000FFC; // Word 1023 (1023 * 4 = 4092 = 0x0FFC)
    seq.is_write      = 1'b1;
    seq.write_data    = 32'h5A5A_A5A5;
    seq.trans_id      = 4'h1;
    seq.start(seqr);

    `uvm_info("TEST", "TC-031: Word 1023 boundary test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC031_BOUNDARY_WORD1023_TEST_SV
