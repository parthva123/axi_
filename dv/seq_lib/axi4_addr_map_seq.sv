// axi4_addr_map_seq.sv
// File        : axi4_addr_map_seq.sv
// Description : Address map sequence for AXI4 slave testbench.
//               Generates address map patterns for Layer 1 tests
//               (TC-M001..TC-M200), testing all regions of memory
//               with systematic address patterns.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_ADDR_MAP_SEQ_SV
`define AXI4_ADDR_MAP_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_addr_map_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Address map regions
  // -----------------------------------------------------------------------
  typedef enum logic [3:0] {
    ADDR_REGION_0 = 4'd0,   // 0x0000 - 0x0FFF (low 4KB)
    ADDR_REGION_1 = 4'd1,   // 0x1000 - 0x1FFF
    ADDR_REGION_2 = 4'd2,   // 0x2000 - 0x2FFF
    ADDR_REGION_3 = 4'd3,   // 0x3000 - 0x3FFF
    ADDR_REGION_4 = 4'd4,   // 0x4000 - 0x4FFF
    ADDR_REGION_5 = 4'd5,   // 0x5000 - 0x5FFF
    ADDR_REGION_6 = 4'd6,   // 0x6000 - 0x6FFF
    ADDR_REGION_7 = 4'd7    // 0x7000 - 0x7FFF
  } addr_region_e;

  // -----------------------------------------------------------------------
  // Configuration
  // -----------------------------------------------------------------------
  rand addr_region_e region;
  rand bit [31:0] base_addr;
  rand bit [7:0]  burst_len;
  rand bit [2:0]  burst_size;
  rand bit [1:0]  burst_type;
  rand bit        is_write;
  rand int unsigned num_transactions;

  // -----------------------------------------------------------------------
  // Address pattern type
  // -----------------------------------------------------------------------
  typedef enum logic [2:0] {
    ADDR_PATTERN_INCREMENTAL = 3'd0,
    ADDR_PATTERN_RANDOM      = 3'd1,
    ADDR_PATTERN_BACK_FILL   = 3'd2,
    ADDR_PATTERN_SKIP        = 3'd3
  } addr_pattern_e;

  rand addr_pattern_e addr_pattern;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_sequence_utils(axi4_addr_map_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_addr_map_seq");
    super.new(name);
    region         = ADDR_REGION_0;
    base_addr      = 32'h00000000;
    burst_len      = 8'd0;
    burst_size     = 3'd2;
    burst_type     = `BURST_INCR;
    is_write       = 1'b1;
    num_transactions = 20;
    addr_pattern   = ADDR_PATTERN_INCREMENTAL;
  endfunction

  // -----------------------------------------------------------------------
  // Body: generate address map pattern
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    bit [31:0] addr;
    int i;

    `uvm_info("SEQ_AM", $sformatf(
      "Starting address map: region=%0d pattern=%0d num=%0d",
      region, addr_pattern, num_transactions), UVM_MEDIUM)

    addr = base_addr;

    for (i = 0; i < num_transactions; i++) begin
      tx = axi4_seq_item::type_id::create($sformatf("tx_%0d", i));

      // Determine address based on pattern
      case (addr_pattern)
        ADDR_PATTERN_INCREMENTAL: begin
          // Sequential increment through memory
          tx.ax_addr = addr;
          addr = addr + (1 << burst_size);
        end
        ADDR_PATTERN_RANDOM: begin
          // Random addresses within region
          assert(tx.randomize() with {
            ax_addr inside {[base_addr : base_addr + 1024]};
            ax_id < 16;
            ax_len == burst_len;
            ax_size == burst_size;
            ax_burst == burst_type;
          });
        end
        ADDR_PATTERN_BACK_FILL: begin
          // Backward address sweep
          tx.ax_addr = base_addr + 1024 - (i * (1 << burst_size));
        end
        ADDR_PATTERN_SKIP: begin
          // Skip every other address
          tx.ax_addr = base_addr + (i * 2 * (1 << burst_size));
        end
        default: begin
          tx.ax_addr = base_addr;
        end
      endcase

      // Set transaction parameters
      tx.ax_id       = i[3:0];
      tx.ax_len      = burst_len;
      tx.ax_size     = burst_size;
      tx.ax_burst    = burst_type;
      tx.ax_lock     = 1'b0;
      tx.ax_cache    = 4'b0000;
      tx.ax_prot     = 3'b000;
      tx.is_write    = is_write;
      tx.w_strb      = (~0) << (tx.ax_size[1:0]);
      tx.w_last      = 1'b1;
      tx.w_data      = {8'd0, $random};
      tx.withhold_bready = 1'b0;
      tx.withhold_rready = 1'b0;

      `uvm_info("SEQ_AM", $sformatf(
        "Addr map[%0d]: addr=0x%0h %s pattern=%0d",
        i, tx.ax_addr, tx.is_write ? "WRITE" : "READ", addr_pattern), UVM_LOW)

      // Send to driver
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end

    `uvm_info("SEQ_AM", "Address map sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_ADDR_MAP_SEQ_SV