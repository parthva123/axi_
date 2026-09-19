// axi4_tc034_every_byte_lane_test.sv
// File        : axi4_tc034_every_byte_lane_test.sv
// Description : Layer 2 test TC-034 - Every Byte Lane Single-Byte Write
//               Tests individual byte-lane writes to lane 0, 1, 2, 3 with corresponding
//               byte strobes (4'b0001, 4'b0010, 4'b0100, 4'b1000) and reads back
//               the full word to verify correct assembly without data corruption.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC034_EVERY_BYTE_LANE_TEST_SV
`define AXI4_TC034_EVERY_BYTE_LANE_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_byte_lane_seq.sv"

class axi4_tc034_every_byte_lane_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc034_every_byte_lane_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc034_every_byte_lane_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-034: Every Byte Lane Single-Byte Write", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC034", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute byte-lane test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_byte_lane_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-034: Starting byte lane test", UVM_MEDIUM)

    seq = axi4_byte_lane_seq::type_id::create("seq");
    seq.target_word_addr = 32'h00000200;
    seq.trans_id         = 4'h4;
    seq.start(seqr);

    `uvm_info("TEST", "TC-034: Byte lane test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC034_EVERY_BYTE_LANE_TEST_SV
