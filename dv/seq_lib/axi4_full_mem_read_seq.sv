// axi4_full_mem_read_seq.sv
// File        : axi4_full_mem_read_seq.sv
// Description : Full memory read sweep sequence for TC-029.
//               Reads all 1024 memory words using 128 bursts of 8 words each.
//               Burst type: INCR, Size: 4 bytes (32-bit).
// Author      : Verification Engineer
// Date        : 2026-09-18
// Revision    : 1.0

`ifndef AXI4_FULL_MEM_READ_SEQ_SV
`define AXI4_FULL_MEM_READ_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_full_mem_read_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [3:0] trans_id;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_object_utils(axi4_full_mem_read_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_full_mem_read_seq");
    super.new(name);
    trans_id = 4'h0;
  endfunction

  // -----------------------------------------------------------------------
  // Body: Read all 1024 words in 128 bursts of 8 words
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    bit [31:0] addr;
    int burst_count = 128;  // 1024 words / 8 words_per_burst = 128 bursts
    int words_per_burst = 8;
    int beats_per_burst = 8; // ax_len = 7 (0-based), so 8 beats

    `uvm_info("SEQ_FULL_MEM_R", $sformatf(
      "Starting full memory read sweep: %0d bursts x %0d words = %0d total words",
      burst_count, words_per_burst, burst_count*words_per_burst), UVM_MEDIUM)

    addr = 32'h00000000;  // Start at memory base

    for (int burst_idx = 0; burst_idx < burst_count; burst_idx++) begin
      tx = axi4_seq_item::type_id::create($sformatf("tx_burst_%0d", burst_idx));

      // Constrain burst parameters
      assert(tx.randomize() with {
        is_write == 1'b0;
        ax_addr == addr;
        ax_id == trans_id;
        ax_len == (beats_per_burst - 1);  // 7 = 8 beats (0-indexed)
        ax_size == 3'b010;                // 4 bytes (32-bit)
        ax_burst == `BURST_INCR;
        ax_lock == 1'b0;
        ax_cache == 4'b0000;
        ax_prot == 3'b000;
        ax_qos == 4'b0000;
      });

      `uvm_info("SEQ_FULL_MEM_R", $sformatf(
        "Burst[%0d/%0d]: addr=0x%08h len=%0d",
        burst_idx+1, burst_count, addr, tx.ax_len+1), UVM_LOW)

      // Send to driver
      start_item(tx);
      finish_item(tx);

      // Increment address: 8 words * 4 bytes/word = 32 bytes
      addr = addr + (words_per_burst * 4);
    end

    `uvm_info("SEQ_FULL_MEM_R", "Full memory read sweep complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_FULL_MEM_READ_SEQ_SV
