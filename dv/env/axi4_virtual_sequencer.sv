// axi4_virtual_sequencer.sv
// File        : axi4_virtual_sequencer.sv
// Description : Virtual sequencer for the AXI4 slave testbench.
//               Holds references to all agent sequencers for
//               cross-channel concurrent sequences (e.g.,
//               concurrent R/W, reset during tx).
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_VIRTUAL_SEQUENCER_SV
`define AXI4_VIRTUAL_SEQUENCER_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_sequencer.sv"

class axi4_virtual_sequencer extends uvm_virtual_sequencer;

  // -----------------------------------------------------------------------
  // References to agent sequencers
  // -----------------------------------------------------------------------
  axi4_sequencer seqr;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_virtual_sequencer)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("VSEQ", "axi4_virtual_sequencer constructed", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: get sequencer reference from config DB
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr)) begin
      `uvm_info("VSEQ", "No sequencer found in config DB", UVM_LOW)
    end
  endfunction

endclass

`endif // AXI4_VIRTUAL_SEQUENCER_SV