// axi4_adjacent_oor_seq.sv
// File        : axi4_adjacent_oor_seq.sv
// Description : Adjacent out-of-range address sequence for TC-032.
//               Tests accesses just below memory base and just above memory limit.
//               Base: 0x00000000, Limit: 0x00001000 (1024 words * 4 bytes).
//               Tests addresses: -4 (0xFFFFFFFC), Limit (0x00001000), Limit+4 (0x00001004).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_ADJACENT_OOR_SEQ_SV
`define AXI4_ADJACENT_OOR_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_adjacent_oor_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [3:0] trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_adjacent_oor_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_adjacent_oor_seq");
    super.new(name);
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Test out-of-range addresses adjacent to boundaries
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    bit [31:0] oor_addresses[4];

    // Addresses to test:
    // 0: Just above upper limit (1024 * 4 = 0x1000)
    // 1: One word above upper limit (0x1004)
    // 2: High memory address (0x80000000)
    // 3: Highest possible 32-bit address (0xFFFFFFFC)
    oor_addresses[0] = 32'h00001000;  // First invalid word
    oor_addresses[1] = 32'h00001004;  // Second invalid word
    oor_addresses[2] = 32'h80000000;  // High address
    oor_addresses[3] = 32'hFFFFFFFC;  // Word below 0 (negative/wrap)

    `uvm_info("SEQ_ADJ_OOR", "Starting adjacent out-of-range test sequence", UVM_MEDIUM)

    foreach (oor_addresses[i]) begin
      bit [31:0] test_addr = oor_addresses[i];

      // 1. Out-of-range Write (expect SLVERR, no memory update)
      tx = axi4_seq_item::type_id::create($sformatf("tx_oor_write_%0d", i));
      assert(tx.randomize() with {
        is_write == 1'b1;
        ax_addr == test_addr;
        ax_id == trans_id;
        ax_len == 8'd0;
        ax_size == 3'b010;
        ax_burst == `BURST_INCR;
        ax_lock == 1'b0;
        ax_cache == 4'b0000;
        ax_prot == 3'b000;
        ax_qos == 4'b0000;
      });

      tx.w_data = 32'hDEAD_DEAD;
      tx.w_strb = 4'b1111;
      tx.w_last = 1'b1;

      `uvm_info("SEQ_ADJ_OOR", $sformatf("Driving OOR Write to addr=0x%08h (expect SLVERR)", test_addr), UVM_LOW)
      start_item(tx);
      finish_item(tx);

      // 2. Out-of-range Read (expect SLVERR, data=0)
      tx = axi4_seq_item::type_id::create($sformatf("tx_oor_read_%0d", i));
      assert(tx.randomize() with {
        is_write == 1'b0;
        ax_addr == test_addr;
        ax_id == trans_id;
        ax_len == 8'd0;
        ax_size == 3'b010;
        ax_burst == `BURST_INCR;
        ax_lock == 1'b0;
        ax_cache == 4'b0000;
        ax_prot == 3'b000;
        ax_qos == 4'b0000;
      });

      `uvm_info("SEQ_ADJ_OOR", $sformatf("Driving OOR Read from addr=0x%08h (expect SLVERR, data=0)", test_addr), UVM_LOW)
      start_item(tx);
      finish_item(tx);
    end

    `uvm_info("SEQ_ADJ_OOR", "Adjacent out-of-range sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_ADJACENT_OOR_SEQ_SV
