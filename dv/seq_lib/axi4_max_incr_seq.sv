// axi4_max_incr_seq.sv
// File        : axi4_max_incr_seq.sv
// Description : Maximum length INCR burst sequence for TC-041.
//               Issues an INCR burst of maximum AXI4 length (ax_len = 255 -> 256 beats).
//               Tests slave beat counter, FIFO capacity, and long burst stability.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_MAX_INCR_SEQ_SV
`define AXI4_MAX_INCR_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_max_incr_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [31:0] start_addr;
  rand bit [3:0]  trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_max_incr_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_max_incr_seq");
    super.new(name);
    start_addr = 32'h0000_0000;
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: 256-beat INCR Write followed by 256-beat INCR Read
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;

    `uvm_info("SEQ_MAX_INCR", $sformatf(
      "Starting max-length INCR burst test (256 beats) at addr=0x%08h", start_addr), UVM_MEDIUM)

    // 1. Max length Write (ax_len = 255 -> 256 beats)
    tx = axi4_seq_item::type_id::create("tx_max_write");
    assert(tx.randomize() with {
      is_write == 1'b1;
      ax_addr == start_addr;
      ax_id == trans_id;
      ax_len == 8'd255;  // 256 BEATS (MAX AXI4 LENGTH)
      ax_size == 3'b010; // 4 bytes per beat -> 1024 bytes total
      ax_burst == `BURST_INCR;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });

    tx.w_data = 32'hBEEF_0000;
    tx.w_strb = 4'b1111;
    tx.w_last = 1'b1;

    `uvm_info("SEQ_MAX_INCR", "Driving 256-beat INCR Write burst...", UVM_LOW)
    start_item(tx);
    finish_item(tx);

    // 2. Max length Read (ax_len = 255 -> 256 beats)
    tx = axi4_seq_item::type_id::create("tx_max_read");
    assert(tx.randomize() with {
      is_write == 1'b0;
      ax_addr == start_addr;
      ax_id == trans_id;
      ax_len == 8'd255;  // 256 BEATS (MAX AXI4 LENGTH)
      ax_size == 3'b010; // 4 bytes per beat
      ax_burst == `BURST_INCR;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });

    `uvm_info("SEQ_MAX_INCR", "Driving 256-beat INCR Read burst...", UVM_LOW)
    start_item(tx);
    finish_item(tx);

    `uvm_info("SEQ_MAX_INCR", "Max-length INCR burst sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_MAX_INCR_SEQ_SV
