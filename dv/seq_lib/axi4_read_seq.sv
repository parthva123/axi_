// axi4_read_seq.sv
// File        : axi4_read_seq.sv
// Description : Base read sequence for AXI4 slave testbench.
//               Sends randomized read transactions with valid
//               burst types, lengths, and sizes.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_READ_SEQ_SV
`define AXI4_READ_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_read_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_sequence_utils(axi4_read_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_read_seq");
    super.new(name);
  endfunction

  // -----------------------------------------------------------------------
  // Body: send randomized read transactions
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    int unsigned num_trans = 10;

    `uvm_info("SEQ_R", $sformatf("Starting read sequence: %0d transactions",
      num_trans), UVM_MEDIUM)

    for (int i = 0; i < num_trans; i++) begin
      tx = axi4_seq_item::type_id::create("tx");

      // Randomize read parameters
      assert(tx.randomize() with {
        is_write == 1'b0;
        ax_id < 16;
        ax_addr < (1 << 30);
        ax_len < 16;
        ax_size < 8;
        ax_burst inside {`BURST_FIXED, `BURST_INCR, `BURST_WRAP};
        ax_lock == 1'b0;
        ax_cache inside {4'b0000, 4'b0010, 4'b0100};
        ax_prot inside {3'b000, 3'b001};
      });

      tx.w_last = 1'b0;

      `uvm_info("SEQ_R", $sformatf("Send read[%0d]: addr=0x%0h len=%0d size=%0d burst=%s",
        i, tx.ax_addr, tx.ax_len, tx.ax_size, tx.burst_name()), UVM_LOW)

      // Start item, send to driver, finish item
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end

    `uvm_info("SEQ_R", "Read sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_READ_SEQ_SV