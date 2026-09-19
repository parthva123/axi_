// axi4_wrap_len_seq.sv
// File        : axi4_wrap_len_seq.sv
// Description : WRAP burst sequence with specific burst lengths for TC-039/TC-040.
//               Supports length 2 (ax_len=1) and length 16 (ax_len=15).
//               Tests wrap boundary wrapping calculation and addressing.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_WRAP_LEN_SEQ_SV
`define AXI4_WRAP_LEN_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_wrap_len_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [7:0]  target_len;   // 8'd1 for len 2, 8'd15 for len 16
  rand bit [31:0] base_addr;
  rand bit [3:0]  trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_wrap_len_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_wrap_len_seq");
    super.new(name);
    target_len = 8'd1;  // Default: length 2 (ax_len = 1)
    base_addr = 32'h0000_0020;
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: WRAP Write then Read-back
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    int wrap_size_bytes;
    bit [31:0] aligned_addr;

    // WRAP burst constraints:
    // 1. Length must be 2, 4, 8, or 16 (ax_len in {1, 3, 7, 15})
    // 2. Start address must be aligned to the total burst size: (AxLEN + 1) * 2^AxSIZE
    wrap_size_bytes = (target_len + 1) * 4; // 4-byte size (ax_size=2)
    aligned_addr = (base_addr / wrap_size_bytes) * wrap_size_bytes;

    `uvm_info("SEQ_WRAP_LEN", $sformatf(
      "Starting WRAP burst test: len=%0d (beats=%0d) addr=0x%08h",
      target_len, target_len+1, aligned_addr), UVM_MEDIUM)

    // 1. WRAP Write Burst
    tx = axi4_seq_item::type_id::create("tx_wrap_write");
    assert(tx.randomize() with {
      is_write == 1'b1;
      ax_addr == aligned_addr;
      ax_id == trans_id;
      ax_len == target_len;
      ax_size == 3'b010;  // 4 bytes
      ax_burst == `BURST_WRAP;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });

    tx.w_data = 32'hWRAP_0001;
    tx.w_strb = 4'b1111;
    tx.w_last = 1'b1;

    `uvm_info("SEQ_WRAP_LEN", $sformatf("Driving WRAP Write: addr=0x%08h len=%0d", aligned_addr, target_len+1), UVM_LOW)
    start_item(tx);
    finish_item(tx);

    // 2. WRAP Read Burst
    tx = axi4_seq_item::type_id::create("tx_wrap_read");
    assert(tx.randomize() with {
      is_write == 1'b0;
      ax_addr == aligned_addr;
      ax_id == trans_id;
      ax_len == target_len;
      ax_size == 3'b010;  // 4 bytes
      ax_burst == `BURST_WRAP;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });

    `uvm_info("SEQ_WRAP_LEN", $sformatf("Driving WRAP Read: addr=0x%08h len=%0d", aligned_addr, target_len+1), UVM_LOW)
    start_item(tx);
    finish_item(tx);

    `uvm_info("SEQ_WRAP_LEN", "WRAP burst sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_WRAP_LEN_SEQ_SV
