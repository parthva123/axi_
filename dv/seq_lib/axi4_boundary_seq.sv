// axi4_boundary_seq.sv
// File        : axi4_boundary_seq.sv
// Description : Memory boundary access sequence for TC-030/TC-031.
//               Tests access to word 0 (address 0x0000) and word 1023 (address 0x0FFC).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_BOUNDARY_SEQ_SV
`define AXI4_BOUNDARY_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_boundary_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [31:0] boundary_addr;  // 0x0000 for word 0, 0x0FFC for word 1023
  rand bit        is_write;
  rand bit [31:0] write_data;
  rand bit [3:0]  trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_boundary_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_boundary_seq");
    super.new(name);
    boundary_addr = 32'h00000000;
    is_write = 1'b1;
    write_data = 32'hBAADF00D;
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Access boundary word (write then read-back)
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;

    `uvm_info("SEQ_BOUNDARY", $sformatf(
      "Starting boundary access: addr=0x%08h is_write=%0d",
      boundary_addr, is_write), UVM_MEDIUM)

    // Write transaction
    if (is_write) begin
      tx = axi4_seq_item::type_id::create("tx_write");
      assert(tx.randomize() with {
        is_write == 1'b1;
        ax_addr == boundary_addr;
        ax_id == trans_id;
        ax_len == 8'd0;         // Single beat
        ax_size == 3'b010;      // 4 bytes (32-bit)
        ax_burst == `BURST_INCR;
        ax_lock == 1'b0;
        ax_cache == 4'b0000;
        ax_prot == 3'b000;
        ax_qos == 4'b0000;
      });

      tx.w_data = write_data;
      tx.w_strb = 4'b1111;  // All byte lanes
      tx.w_last = 1'b1;

      `uvm_info("SEQ_BOUNDARY", $sformatf(
        "Write: addr=0x%08h data=0x%08h", boundary_addr, write_data), UVM_LOW)

      start_item(tx);
      finish_item(tx);
    end

    // Read transaction
    tx = axi4_seq_item::type_id::create("tx_read");
    assert(tx.randomize() with {
      is_write == 1'b0;
      ax_addr == boundary_addr;
      ax_id == trans_id;
      ax_len == 8'd0;         // Single beat
      ax_size == 3'b010;      // 4 bytes (32-bit)
      ax_burst == `BURST_INCR;
      ax_lock == 1'b0;
      ax_cache == 4'b0000;
      ax_prot == 3'b000;
      ax_qos == 4'b0000;
    });

    `uvm_info("SEQ_BOUNDARY", $sformatf(
      "Read: addr=0x%08h", boundary_addr), UVM_LOW)

    start_item(tx);
    finish_item(tx);

    `uvm_info("SEQ_BOUNDARY", "Boundary access complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_BOUNDARY_SEQ_SV
