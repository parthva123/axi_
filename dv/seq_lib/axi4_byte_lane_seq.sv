// axi4_byte_lane_seq.sv
// File        : axi4_byte_lane_seq.sv
// Description : Single-byte write sequence across each byte lane for TC-034.
//               Initializes a 32-bit word, then writes to each byte lane
//               individually (lanes 0, 1, 2, 3) using single-byte writes
//               with appropriate WSTRB (0001, 0010, 0100, 1000).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_BYTE_LANE_SEQ_SV
`define AXI4_BYTE_LANE_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_byte_lane_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [31:0] target_word_addr;
  rand bit [3:0]  trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_byte_lane_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_byte_lane_seq");
    super.new(name);
    target_word_addr = 32'h00000080;
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Test each byte lane individually
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    bit [7:0] byte_data[4];
    bit [3:0] strobes[4];

    byte_data[0] = 8'h11;
    byte_data[1] = 8'h22;
    byte_data[2] = 8'h33;
    byte_data[3] = 8'h44;

    strobes[0] = 4'b0001;
    strobes[1] = 4'b0010;
    strobes[2] = 4'b0100;
    strobes[3] = 4'b1000;

    `uvm_info("SEQ_BYTE_LANE", $sformatf(
      "Starting individual byte-lane test on word addr=0x%08h", target_word_addr), UVM_MEDIUM)

    // Step 0: Initialize word to all zeros
    tx = axi4_seq_item::type_id::create("tx_init");
    assert(tx.randomize() with {
      is_write == 1'b1;
      ax_addr == target_word_addr;
      ax_id == trans_id;
      ax_len == 8'd0;
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
    });
    tx.w_data = 32'h0000_0000;
    tx.w_strb = 4'b1111;
    tx.w_last = 1'b1;
    start_item(tx);
    finish_item(tx);

    // Steps 1-4: Write each byte lane sequentially
    for (int lane = 0; lane < 4; lane++) begin
      bit [31:0] byte_addr = target_word_addr + lane;

      tx = axi4_seq_item::type_id::create($sformatf("tx_lane_%0d", lane));
      assert(tx.randomize() with {
        is_write == 1'b1;
        ax_addr == byte_addr;
        ax_id == trans_id;
        ax_len == 8'd0;
        ax_size == 3'b000;  // 1-byte transfer
        ax_burst == `BURST_INCR;
      });

      // Position byte data at appropriate lane
      tx.w_data = (byte_data[lane] << (lane * 8));
      tx.w_strb = strobes[lane];
      tx.w_last = 1'b1;

      `uvm_info("SEQ_BYTE_LANE", $sformatf(
        "Lane %0d: addr=0x%08h byte=0x%02h strb=4'b%04b",
        lane, byte_addr, byte_data[lane], strobes[lane]), UVM_LOW)

      start_item(tx);
      finish_item(tx);
    end

    // Step 5: Read back the full 32-bit word
    tx = axi4_seq_item::type_id::create("tx_final_read");
    assert(tx.randomize() with {
      is_write == 1'b0;
      ax_addr == target_word_addr;
      ax_id == trans_id;
      ax_len == 8'd0;
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
    });

    `uvm_info("SEQ_BYTE_LANE", "Reading back assembled 32-bit word (expect 0x44332211)", UVM_LOW)
    start_item(tx);
    finish_item(tx);

    `uvm_info("SEQ_BYTE_LANE", "Byte lane test sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_BYTE_LANE_SEQ_SV
