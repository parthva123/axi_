// axi4_tc033_wstrb_zero_test.sv
// File        : axi4_tc033_wstrb_zero_test.sv
// Description : Layer 2 test TC-033 - WSTRB All-Zero Write
//               Verifies that writes with WSTRB=4'b0000 do not modify memory.
//               Steps: 1) Init write with valid data
//                      2) Write with WSTRB=0
//                      3) Read back to confirm no change
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_TC033_WSTRB_ZERO_TEST_SV
`define AXI4_TC033_WSTRB_ZERO_TEST_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_wstrb_zero_seq.sv"

class axi4_tc033_wstrb_zero_test extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_tc033_wstrb_zero_test)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_tc033_wstrb_zero_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    `uvm_info("TEST", "TC-033: WSTRB All-Zero Write", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_fatal("TC033", "Failed to get sequencer from config DB")
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute WSTRB=0 test
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    axi4_wstrb_zero_seq seq;

    phase.raise_objection(this);
    `uvm_info("TEST", "TC-033: Starting WSTRB all-zero write test", UVM_MEDIUM)

    seq = axi4_wstrb_zero_seq::type_id::create("seq");
    seq.target_addr    = 32'h00000100;
    seq.trans_id       = 4'h3;
    seq.init_data      = 32'hAAAA_5555;
    seq.attempted_data = 32'h1234_5678;
    seq.start(seqr);

    `uvm_info("TEST", "TC-033: WSTRB all-zero write test complete", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif // AXI4_TC033_WSTRB_ZERO_TEST_SV
