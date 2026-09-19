// axi4_ref_model.sv
// File        : axi4_ref_model.sv
// Description : Reference model (memory + behavior model) for the AXI4 slave DUT.
//               Models: write channel (AW+W→B), read channel (AR→R),
//               narrow-read simplification (no byte-lane shifting),
//               SLVERR stickiness, address-range checking,
//               WRAP burst constraints (len in {1,3,7,15}).
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_REF_MODEL_SV
`define AXI4_REF_MODEL_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_ref_model extends uvm_component;

  // -----------------------------------------------------------------------
  // Memory array (32-bit words, depth = C_S_AXI_MEM_DEPTH)
  // -----------------------------------------------------------------------
  reg [31:0] mem [0:`C_S_AXI_MEM_DEPTH-1];

  // -----------------------------------------------------------------------
  // SLVERR stickiness: once SLVERR in a burst, stays SLVERR
  // -----------------------------------------------------------------------
  bit slverr_sticky;

  // -----------------------------------------------------------------------
  // Current burst tracking for stickiness
  // -----------------------------------------------------------------------
  bit [31:0]  burst_start_addr;
  bit [7:0]   burst_len;
  bit [2:0]   burst_size;
  bit [1:0]   burst_type;
  bit         burst_in_progress;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_ref_model)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_ref_model", uvm_component parent);
    super.new(name, parent);
    slverr_sticky = 1'b0;
    burst_in_progress = 1'b0;
    `uvm_info("REF", "axi4_ref_model constructed", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Build phase
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Initialize memory to 0
    mem = '{default: '0};
    `uvm_info("REF", "Memory initialized to 0", UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Reset the reference model (called on reset assertion)
  // -----------------------------------------------------------------------
  function void reset();
    mem = '{default: '0};
    slverr_sticky = 1'b0;
    burst_in_progress = 1'b0;
    `uvm_info("REF", "Reference model reset", UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Predict B response for a write transaction
  // -----------------------------------------------------------------------
  function bit [1:0] predict_b_resp(axi4_seq_item tx);
    bit [31:0] addr = tx.ax_addr;
    bit [7:0]  len  = tx.ax_len;
    bit [2:0]  size = tx.ax_size;
    bit [1:0]  burst = tx.ax_burst;

    // Check if address is in valid range
    if (!axi4_in_range(addr, len, size, burst)) begin
      `uvm_info("REF", $sformatf("B: addr=0x%0h out of range → SLVERR", addr), UVM_LOW)
      return `RESP_SLVERR;
    end

    // Check WRAP burst constraints (len must be in {1,3,7,15} and address aligned)
    if (burst == `BURST_WRAP) begin
      if (len != 8'd1 && len != 8'd3 && len != 8'd7 && len != 8'd15) begin
        `uvm_info("REF", $sformatf("B: WRAP len=%0d not in {1,3,7,15} → SLVERR", len), UVM_LOW)
        return `RESP_SLVERR;
      end
      // Address must be aligned to burst size * data width
      if (addr[2+size] !== 1'b0) begin
        `uvm_info("REF", $sformatf("B: WRAP addr=0x%0h not aligned → SLVERR", addr), UVM_LOW)
        return `RESP_SLVERR;
      end
    end

    return `RESP_OKAY;
  endfunction

  // -----------------------------------------------------------------------
  // Predict R data for a read transaction (narrow-read simplification:
  // slave does NOT do byte-lane shifting — returns word from memory)
  // -----------------------------------------------------------------------
  function bit [31:0] predict_r_data(axi4_seq_item tx);
    bit [31:0] addr = tx.ax_addr;
    bit [7:0]  len  = tx.ax_len;
    bit [2:0]  size = tx.ax_size;
    bit [1:0]  burst = tx.ax_burst;

    // Check if address is in valid range
    if (!axi4_in_range(addr, len, size, burst)) begin
      `uvm_info("REF", $sformatf("R: addr=0x%0h out of range → SLVERR", addr), UVM_LOW)
      return '0;
    end

    // Narrow read simplification: return word from memory at word address
    // No byte-lane shifting — matches DUT behavior exactly
    int word_idx = addr[`ADDR_LSB +: `MEM_ADDR_BITS];
    if (word_idx < `C_S_AXI_MEM_DEPTH) begin
      return mem[word_idx];
    end else begin
      return '0;
    end
  endfunction

  // -----------------------------------------------------------------------
  // Predict R response for a read transaction
  // -----------------------------------------------------------------------
  function bit [1:0] predict_r_resp(axi4_seq_item tx);
    bit [31:0] addr = tx.ax_addr;
    bit [7:0]  len  = tx.ax_len;
    bit [2:0]  size = tx.ax_size;
    bit [1:0]  burst = tx.ax_burst;

    if (!axi4_in_range(addr, len, size, burst)) begin
      return `RESP_SLVERR;
    end
    return `RESP_OKAY;
  endfunction

  // -----------------------------------------------------------------------
  // Process a write transaction: store data in memory
  // -----------------------------------------------------------------------
  function void process_write(axi4_seq_item tx);
    bit [31:0] addr = tx.ax_addr;
    bit [7:0]  len  = tx.ax_len;
    bit [2:0]  size = tx.ax_size;
    bit [1:0]  burst = tx.ax_burst;

    // Check if address is in valid range
    if (!axi4_in_range(addr, len, size, burst)) begin
      `uvm_info("REF", $sformatf("W: addr=0x%0h out of range → SLVERR, not storing", addr), UVM_LOW)
      slverr_sticky = 1'b1;
      return;
    end

    // Reset SLVERR stickiness on successful write
    slverr_sticky = 1'b0;

    // Store data in memory (with byte strobe)
    int num_beats = len + 1;
    for (int i = 0; i < num_beats; i++) begin
      int word_idx = (addr + (i << size)) [`ADDR_LSB +: `MEM_ADDR_BITS];
      if (word_idx < `C_S_AXI_MEM_DEPTH) begin
        // Apply write strobe
        mem[word_idx] = apply_wstrb(tx.w_data, tx.w_strb, size);
      end
    end

    `uvm_info("REF", $sformatf("W: stored %0d beats at addr=0x%0h", num_beats, addr), UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Process a read transaction: return data from memory
  // -----------------------------------------------------------------------
  function void process_read(axi4_seq_item tx);
    bit [31:0] addr = tx.ax_addr;
    bit [7:0]  len  = tx.ax_len;
    bit [2:0]  size = tx.ax_size;
    bit [1:0]  burst = tx.ax_burst;

    // Check if address is in valid range
    if (!axi4_in_range(addr, len, size, burst)) begin
      `uvm_info("REF", $sformatf("R: addr=0x%0h out of range → SLVERR", addr), UVM_LOW)
      slverr_sticky = 1'b1;
      return;
    end

    // Reset SLVERR stickiness on successful read
    slverr_sticky = 1'b0;

    `uvm_info("REF", $sformatf("R: read from addr=0x%0h", addr), UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Check if address range is valid for a burst
  // -----------------------------------------------------------------------
  function bit axi4_in_range(bit [31:0] addr, bit [7:0] len, bit [2:0] size, bit [1:0] burst);
    int num_beats = len + 1;
    int transfer_size = (1 << size);
    bit [31:0] last_addr = addr + (num_beats * transfer_size) - 1;

    // Check if last address wraps within legal bounds
    // For simplicity, check if address + burst size stays within memory
    if (last_addr >= (`C_S_AXI_MEM_DEPTH << 2)) begin
      return 1'b0;
    end

    // Check WRAP burst alignment
    if (burst == `BURST_WRAP) begin
      if (len != 8'd1 && len != 8'd3 && len != 8'd7 && len != 8'd15) begin
        return 1'b0;
      end
    end

    return 1'b1;
  endfunction

  // -----------------------------------------------------------------------
  // Apply write strobe to data
  // -----------------------------------------------------------------------
  function bit [31:0] apply_wstrb(bit [31:0] data, bit [`C_S_AXI_STRB_WIDTH-1:0] wstrb, bit [2:0] size);
    bit [31:0] result = '0;
    int num_bytes = (1 << size);
    for (int i = 0; i < num_bytes; i++) begin
      if (wstrb[i]) begin
        result[i*8 +: 8] = data[i*8 +: 8];
      end
    end
    return result;
  endfunction

  // -----------------------------------------------------------------------
  // Get SLVERR stickiness status
  // -----------------------------------------------------------------------
  function bit get_slverr_sticky();
    return slverr_sticky;
  endfunction

endclass

`endif // AXI4_REF_MODEL_SV