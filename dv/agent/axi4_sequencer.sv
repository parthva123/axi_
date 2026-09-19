// axi4_sequencer.sv
// File        : axi4_sequencer.sv
// Description : UVM sequencer for the AXI4 slave testbench.
//               Arbiter-less sequencer; sequences drive write
//               and read transactions through the same item
//               port. Virtual sequencer used for cross-channel
//               sequences (concurrent R/W, reset during tx).
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_SEQUENCER_SV
`define AXI4_SEQUENCER_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"

class axi4_sequencer extends uvm_sequencer #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_sequencer)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: standard setup
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SEQ", "axi4_sequencer built", UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Connect phase: nothing to connect for this simple sequencer
  // -----------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SEQ", "axi4_sequencer connected", UVM_LOW)
  endfunction

endclass

`endif // AXI4_SEQUENCER_SV