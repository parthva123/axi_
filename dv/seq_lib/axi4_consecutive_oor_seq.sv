// axi4_consecutive_oor_seq.sv
// File        : axi4_consecutive_oor_seq.sv
// Description : Consecutive out-of-range bursts sequence for TC-038.
//               Issues multiple consecutive out-of-range write and read
//               bursts to verify SLVERR response handling and that the
//               slave correctly ignores invalid addresses repeatedly.
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_CONSECUTIVE_OOR_SEQ_SV
`define AXI4_CONSECUTIVE_OOR_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_consecutive_oor_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand int unsigned num_oor_transactions;
  rand bit [3:0]    trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_consecutive_oor_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_consecutive_oor_seq");
    super.new(name);
    num_oor_transactions = 10;
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Issue consecutive OOR writes and reads
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    bit [31:0] oor_addr;

    `uvm_info("SEQ_CONSEC_OOR", $sformatf(
      "Starting consecutive OOR burst sequence: %0d transactions", num_oor_transactions), UVM_MEDIUM)

    for (int i = 0; i < num_oor_transactions; i++) begin
      // Generate different out-of-range addresses
      // Base memory is 0x0000-0x0FFF (1024 words * 4 bytes)
      // OOR addresses: 0x1000, 0x2000, 0x8000, 0xFFFF_0000, etc.
      case (i % 4)
        0: oor_addr = 32'h0000_1000;
        1: oor_addr = 32'h0000_2000;
        2: oor_addr = 32'h8000_0000;
        3: oor_addr = 32'hFFFF_F000;
      endcase

      // OOR Write burst
      tx = axi4_seq_item::type_id::create($sformatf("tx_oor_write_%0d", i));
      assert(tx.randomize() with {
        is_write == 1'b1;
        ax_addr == oor_addr;
        ax_id == trans_id;
        ax_len == 8'd7;     // 8-beat burst
        ax_size == 3'b010;
        ax_burst == `BURST_INCR;
      });
      tx.w_data = 32'hDEAD_0000 | i;
      tx.w_strb = 4'b1111;
      tx.w_last = 1'b1;

      `uvm_info("SEQ_CONSEC_OOR", $sformatf(
        "OOR Write[%0d]: addr=0x%08h (expect SLVERR)", i, oor_addr), UVM_LOW)
      start_item(tx);
      finish_item(tx);

      // OOR Read burst
      tx = axi4_seq_item::type_id::create($sformatf("tx_oor_read_%0d", i));
      assert(tx.randomize() with {
        is_write == 1'b0;
        ax_addr == oor_addr;
        ax_id == trans_id;
        ax_len == 8'd7;     // 8-beat burst
        ax_size == 3'b010;
        ax_burst == `BURST_INCR;
      });

      `uvm_info("SEQ_CONSEC_OOR", $sformatf(
        "OOR Read[%0d]: addr=0x%08h (expect SLVERR)", i, oor_addr), UVM_LOW)
      start_item(tx);
      finish_item(tx);
    end

    `uvm_info("SEQ_CONSEC_OOR", "Consecutive OOR burst sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_CONSECUTIVE_OOR_SEQ_SV
