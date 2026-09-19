// axi4_reset_during_burst_seq.sv
// File        : axi4_reset_during_burst_seq.sv
// Description : Reset during active burst sequence for TC-036/TC-037.
//               Initiates a burst transaction, then applies reset mid-burst
//               to verify DUT recovery. Configurable for write or read bursts.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_RESET_DURING_BURST_SEQ_SV
`define AXI4_RESET_DURING_BURST_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_reset_during_burst_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit        is_write;
  rand bit [31:0] start_addr;
  rand bit [7:0]  burst_len;
  rand bit [3:0]  trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_reset_during_burst_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_reset_during_burst_seq");
    super.new(name);
    is_write = 1'b1;
    start_addr = 32'h00000100;
    burst_len = 8'd15;  // 16-beat burst
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Start burst, apply reset mid-transaction (via interface),
  //       then verify DUT can recover with new transaction
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;

    `uvm_info("SEQ_RESET_BURST", $sformatf(
      "Starting reset-during-burst test: %s burst addr=0x%08h len=%0d",
      is_write ? "WRITE" : "READ", start_addr, burst_len+1), UVM_MEDIUM)

    // Step 1: Initiate burst transaction
    tx = axi4_seq_item::type_id::create("tx_burst");
    assert(tx.randomize() with {
      is_write == local::is_write;
      ax_addr == start_addr;
      ax_id == trans_id;
      ax_len == burst_len;
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
    });

    if (is_write) begin
      tx.w_data = 32'hBAD0_0000;
      tx.w_strb = 4'b1111;
      tx.w_last = 1'b1;
    end

    `uvm_info("SEQ_RESET_BURST", "Step 1: Starting burst transaction", UVM_LOW)
    start_item(tx);

    // NOTE: Reset will be applied externally by the test at the appropriate time.
    // The sequence starts the transaction but the test is responsible for
    // triggering reset via the interface after a few beats.

    finish_item(tx);

    // Step 2: Wait for reset to complete (managed by test)
    // The test applies reset and waits for deassertion

    // Step 3: Try a new transaction to verify recovery
    tx = axi4_seq_item::type_id::create("tx_recovery");
    assert(tx.randomize() with {
      is_write == local::is_write;
      ax_addr == start_addr + 32'h40;
      ax_id == trans_id;
      ax_len == 8'd0;  // Single beat
      ax_size == 3'b010;
      ax_burst == `BURST_INCR;
    });

    if (is_write) begin
      tx.w_data = 32'hC0DE_0001;
      tx.w_strb = 4'b1111;
      tx.w_last = 1'b1;
    end

    `uvm_info("SEQ_RESET_BURST", "Step 3: Attempting recovery transaction post-reset", UVM_LOW)
    start_item(tx);
    finish_item(tx);

    `uvm_info("SEQ_RESET_BURST", "Reset-during-burst sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_RESET_DURING_BURST_SEQ_SV
