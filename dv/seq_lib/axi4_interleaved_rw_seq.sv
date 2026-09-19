// axi4_interleaved_rw_seq.sv
// File        : axi4_interleaved_rw_seq.sv
// Description : Interleaved read/write sequence across memory for TC-035.
//               Alternates between write and read operations across
//               scattered memory addresses to stress the independent
//               FSMs and memory arbitration.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_INTERLEAVED_RW_SEQ_SV
`define AXI4_INTERLEAVED_RW_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_interleaved_rw_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand int unsigned num_pairs;
  rand bit [3:0]    trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_interleaved_rw_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_interleaved_rw_seq");
    super.new(name);
    num_pairs = 32;
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Interleave writes and reads
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item w_tx;
    axi4_seq_item r_tx;
    bit [31:0] wr_addr;
    bit [31:0] rd_addr;

    `uvm_info("SEQ_INTERLEAVED", $sformatf(
      "Starting interleaved R/W sequence: %0d iterations", num_pairs), UVM_MEDIUM)

    for (int i = 0; i < num_pairs; i++) begin
      // Pick random valid word-aligned addresses
      wr_addr = (i * 32) % 4096;
      rd_addr = ((num_pairs - 1 - i) * 32) % 4096;

      // 1. Write transaction
      w_tx = axi4_seq_item::type_id::create($sformatf("w_tx_%0d", i));
      assert(w_tx.randomize() with {
        is_write == 1'b1;
        ax_addr == wr_addr;
        ax_id == trans_id;
        ax_len == 8'd3;         // 4-beat burst
        ax_size == 3'b010;      // 4 bytes
        ax_burst == `BURST_INCR;
      });
      w_tx.w_data = 32'hA000_0000 | (i << 8);
      w_tx.w_strb = 4'b1111;
      w_tx.w_last = 1'b1;

      `uvm_info("SEQ_INTERLEAVED", $sformatf(
        "Pair[%0d] Write: addr=0x%08h len=%0d", i, wr_addr, w_tx.ax_len+1), UVM_LOW)
      start_item(w_tx);
      finish_item(w_tx);

      // 2. Read transaction
      r_tx = axi4_seq_item::type_id::create($sformatf("r_tx_%0d", i));
      assert(r_tx.randomize() with {
        is_write == 1'b0;
        ax_addr == rd_addr;
        ax_id == trans_id;
        ax_len == 8'd3;         // 4-beat burst
        ax_size == 3'b010;      // 4 bytes
        ax_burst == `BURST_INCR;
      });

      `uvm_info("SEQ_INTERLEAVED", $sformatf(
        "Pair[%0d] Read: addr=0x%08h len=%0d", i, rd_addr, r_tx.ax_len+1), UVM_LOW)
      start_item(r_tx);
      finish_item(r_tx);
    end

    `uvm_info("SEQ_INTERLEAVED", "Interleaved R/W sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_INTERLEAVED_RW_SEQ_SV
