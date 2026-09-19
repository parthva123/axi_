// axi4_write_seq.sv
// File        : axi4_write_seq.sv
// Description : Base write sequence for AXI4 slave testbench.
//               Sends randomized write transactions with valid
//               burst types, lengths, and sizes.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_WRITE_SEQ_SV
`define AXI4_WRITE_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_write_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_sequence_utils(axi4_write_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_write_seq");
    super.new(name);
  endfunction

  // -----------------------------------------------------------------------
  // Body: send randomized write transactions
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    int unsigned num_trans = 10;

    `uvm_info("SEQ_W", $sformatf("Starting write sequence: %0d transactions",
      num_trans), UVM_MEDIUM)

    for (int i = 0; i < num_trans; i++) begin
      tx = axi4_seq_item::type_id::create("tx");

      // Randomize write parameters
      assert(tx.randomize() with {
        is_write == 1'b1;
        ax_id < 16;
        ax_addr < (1 << 30);   // 1GB address space
        ax_len < 16;           // 1-16 beats
        ax_size < 8;           // 1B to 128B
        ax_burst inside {`BURST_FIXED, `BURST_INCR, `BURST_WRAP};
        ax_lock == 1'b0;
        ax_cache inside {4'b0000, 4'b0010, 4'b0100};
        ax_prot inside {3'b000, 3'b001};
      });

      // Set w_strb based on data size
      tx.w_strb = (~0) << (tx.ax_size[1:0]);
      tx.w_last = 1'b1;

      `uvm_info("SEQ_W", $sformatf("Send write[%0d]: addr=0x%0h len=%0d size=%0d burst=%s",
        i, tx.ax_addr, tx.ax_len, tx.ax_size, tx.burst_name()), UVM_LOW)

      // Start item, send to driver, finish item
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end

    `uvm_info("SEQ_W", "Write sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_WRITE_SEQ_SV