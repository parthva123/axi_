// axi4_wstrb_zero_seq.sv
// File        : axi4_wstrb_zero_seq.sv
// Description : WSTRB all-zero write sequence for TC-033.
//               Writes with WSTRB = 4'b0000 to verify no memory update occurs.
//               Initializes memory, writes with all-zero strobes, reads back to verify.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_WSTRB_ZERO_SEQ_SV
`define AXI4_WSTRB_ZERO_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_wstrb_zero_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [31:0] target_addr;
  rand bit [3:0]  trans_id;
  rand bit [31:0] init_data;
  rand bit [31:0] attempted_data;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_wstrb_zero_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_wstrb_zero_seq");
    super.new(name);
    target_addr = 32'h00000040;
    trans_id = 4'h0;
    init_data = 32'hAAAA_5555;
    attempted_data = 32'h1234_5678;
  endfunction

  // -----------------------------------------------------------------------
  // Body: 1. Init write with valid strobes
  //       2. Write with WSTRB=0000
  //       3. Read back to confirm data didn't change
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;

    `uvm_info("SEQ_WSTRB_ZERO", $sformatf(
      "Starting WSTRB=0 test on addr=0x%08h", target_addr), UVM_MEDIUM)

    // Step 1: Initialize target word with known data
    tx = axi4_seq_item::type_id::create("tx_init_write");
    assert(tx.randomize() with {
      is_write == 1'b1;
      ax_addr == target_addr;
      ax_id == trans_id;
      ax_len == 8'd0;
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });
    tx.w_data = init_data;
    tx.w_strb = 4'b1111;
    tx.w_last = 1'b1;

    `uvm_info("SEQ_WSTRB_ZERO", $sformatf("Step 1: Init write data=0x%08h", init_data), UVM_LOW)
    start_item(tx);
    finish_item(tx);

    // Step 2: Attempt write with all-zero WSTRB
    tx = axi4_seq_item::type_id::create("tx_zero_wstrb_write");
    assert(tx.randomize() with {
      is_write == 1'b1;
      ax_addr == target_addr;
      ax_id == trans_id;
      ax_len == 8'd0;
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });
    tx.w_data = attempted_data;
    tx.w_strb = 4'b0000;  // ALL ZERO STROBE
    tx.w_last = 1'b1;

    `uvm_info("SEQ_WSTRB_ZERO", $sformatf(
      "Step 2: Write with WSTRB=4'b0000, attempted_data=0x%08h", attempted_data), UVM_LOW)
    start_item(tx);
    finish_item(tx);

    // Step 3: Read back and verify data unchanged
    tx = axi4_seq_item::type_id::create("tx_verify_read");
    assert(tx.randomize() with {
      is_write == 1'b0;
      ax_addr == target_addr;
      ax_id == trans_id;
      ax_len == 8'd0;
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });

    `uvm_info("SEQ_WSTRB_ZERO", "Step 3: Read back to verify unchanged data", UVM_LOW)
    start_item(tx);
    finish_item(tx);

    `uvm_info("SEQ_WSTRB_ZERO", "WSTRB=0 sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_WSTRB_ZERO_SEQ_SV
