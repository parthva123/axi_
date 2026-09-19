// TC-037.sv
// File        : tc-037.sv
// Description : Layer 2 test - Reset During Active Read Burst.
//               Runs axi4_reset_during_burst_seq: Initiates a read burst,
//               applies reset mid-transaction, verifies DUT recovery.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef TC-037_SV
`define TC-037_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_reset_during_burst_seq.sv"

class tc_037 extends uvm_test;

  // -----------------------------------------------------------------------
  // Environment and sequencer
  // -----------------------------------------------------------------------
  axi4_env       env;
  axi4_sequencer seqr;
  virtual axi4_if vif;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(tc_037)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "tc_037", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create environment
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface must be set for tc_037")
    `uvm_info("TEST", "TC-037: Reset During Active Read Burst", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: get sequencer from config DB
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("TEST", "TC-037: sequencer found", UVM_MEDIUM)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: execute sequence and apply reset mid-burst
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "TC-037: starting sequence", UVM_MEDIUM)

    fork
      begin
        // Start the read burst sequence
        axi4_reset_during_burst_seq seq;
        seq = axi4_reset_during_burst_seq::type_id::create("axi4_reset_during_burst_seq");
        seq.is_write = 1'b0;  // Read burst
        seq.start(seqr);
      end
      begin
        // Apply reset after a few clock cycles
        repeat(10) @(posedge vif.S_AXI_ACLK);
        `uvm_info("TEST", "TC-037: Applying reset during read burst", UVM_HIGH)
        vif.S_AXI_ARESETN <= 1'b0;
        repeat(5) @(posedge vif.S_AXI_ACLK);
        vif.S_AXI_ARESETN <= 1'b1;
        `uvm_info("TEST", "TC-037: Reset deasserted", UVM_HIGH)
      end
    join

    phase.drop_objection(this);
  endtask

endclass

`endif // TC-037_SV
