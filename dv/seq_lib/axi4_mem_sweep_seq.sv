// axi4_mem_sweep_seq.sv
// File        : axi4_mem_sweep_seq.sv
// Description : Memory sweep sequence for AXI4 slave testbench.
//               Systematically sweeps through memory addresses
//               (TC-M001..TC-M100 style), testing all memory
//               word boundaries with incremental addresses.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_MEM_SWEEP_SEQ_SV
`define AXI4_MEM_SWEEP_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_mem_sweep_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration knobs
  // -----------------------------------------------------------------------
  rand bit [31:0] start_addr;
  rand bit [31:0] end_addr;
  rand bit [31:0] step;
  rand bit [7:0]  burst_len;
  rand bit [2:0]  burst_size;
  rand bit [1:0]  burst_type;
  rand int unsigned  num_transactions;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_sequence_utils(axi4_mem_sweep_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_mem_sweep_seq");
    super.new(name);
    start_addr = 32'h00000000;
    end_addr   = 32'h00000FFF;   // 4KB memory range
    step       = 32'h00000010;   // 16-byte step
    burst_len  = 8'd0;           // Single beat by default
    burst_size = 3'd2;           // 4-byte transfers
    burst_type = `BURST_INCR;
    num_transactions = 50;
  endfunction

  // -----------------------------------------------------------------------
  // Body: sweep through memory addresses
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    bit [31:0] addr;

    `uvm_info("SEQ_SWEEP", $sformatf(
      "Starting memory sweep: start=0x%0h end=0x%0h step=0x%0h num=%0d",
      start_addr, end_addr, step, num_transactions), UVM_MEDIUM)

    addr = start_addr;
    for (int i = 0; i < num_transactions; i++) begin
      if (addr > end_addr) begin
        `uvm_info("SEQ_SWEEP", "Reached end address, wrapping to start", UVM_LOW)
        addr = start_addr;
      end

      tx = axi4_seq_item::type_id::create($sformatf("tx_%0d", i));

      // Constrain sweep parameters
      assert(tx.randomize() with {
        is_write == 1'b1;                     // Write sweep
        ax_addr == addr;
        ax_id < 16;
        ax_len == burst_len;
        ax_size == burst_size;
        ax_burst == burst_type;
        ax_lock == 1'b0;
        ax_cache == 4'b0000;
        ax_prot == 3'b000;
      });

      // Write data pattern to memory
      tx.w_data = {8'd0, $random} & 32'hFFFFFFFF;
      tx.w_strb = (~0) << (tx.ax_size[1:0]);
      tx.w_last = 1'b1;

      `uvm_info("SEQ_SWEEP", $sformatf("Sweep[%0d]: addr=0x%0h data=0x%0h",
        i, addr, tx.w_data), UVM_LOW)

      // Send to driver
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);

      // Increment address
      addr = addr + step;
    end

    `uvm_info("SEQ_SWEEP", "Memory sweep complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_MEM_SWEEP_SEQ_SV