// axi4_wlast_mismatch_seq.sv
// File        : axi4_wlast_mismatch_seq.sv
// Description : WLAST timing mismatch sequence for AXI4 slave testbench.
//               Tests cases where WLAST is asserted early or late
//               relative to the actual burst length (TC-020..TC-021).
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_WLAST_MISMATCH_SEQ_SV
`define AXI4_WLAST_MISMATCH_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_wlast_mismatch_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration: WLAST mismatch mode
  //   0 = WLAST early (asserted before last beat)
  //   1 = WLAST late (asserted after last beat)
  // -----------------------------------------------------------------------
  rand bit [1:0] wlast_mode;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_sequence_utils(axi4_wlast_mismatch_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_wlast_mismatch_seq");
    super.new(name);
    wlast_mode = 2'b00;
  endfunction

  // -----------------------------------------------------------------------
  // Body: send write transactions with WLAST mismatch
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;
    int unsigned num_beats;

    `uvm_info("SEQ_WLST", "Starting WLAST mismatch sequence", UVM_MEDIUM)

    // Test all burst types with WLAST mismatch
    for (int burst = 0; burst < 3; burst++) begin
      bit [1:0] burst_type;
      case (burst)
        0: burst_type = `BURST_FIXED;
        1: burst_type = `BURST_INCR;
        2: burst_type = `BURST_WRAP;
      endcase

      for (int len_idx = 0; len_idx < 2; len_idx++) begin
        bit [7:0] len;
        if (len_idx == 0) len = 8'd0;       // Single beat
        else              len = 8'd3;       // 4 beats

        tx = axi4_seq_item::type_id::create($sformatf("tx_b%0d_l%0d", burst, len));

        // Setup transaction
        tx.ax_id     = burst[1:0];
        tx.ax_addr   = (len == 8'd0) ? 32'h00000000 : 32'h00001000;
        tx.ax_len    = len;
        tx.ax_size   = 3'd2;    // 4-byte transfer
        tx.ax_burst  = burst_type;
        tx.ax_lock   = 1'b0;
        tx.ax_cache  = 4'b0000;
        tx.ax_prot   = 3'b000;
        tx.is_write  = 1'b1;
        tx.w_strb    = 4'hF;
        tx.w_last    = 1'b1;
        tx.w_data    = {8'd0, $random};

        num_beats = len + 1;

        // Apply WLAST mismatch
        if (wlast_mode == 2'b00) begin
          // WLAST early: assert WLAST on first beat
          tx.w_last = 1'b1;
          `uvm_info("SEQ_WLST", "WLAST early mode", UVM_LOW)
        end else if (wlast_mode == 2'b01) begin
          // WLAST late: deassert WLAST until final beat
          tx.w_last = 1'b0;
          `uvm_info("SEQ_WLST", "WLAST late mode", UVM_LOW)
        end

        `uvm_info("SEQ_WLST", $sformatf(
          "Send wlast_mismatch[%0d]: burst=%s len=%0d wlast=%0d",
          burst, tx.burst_name(), tx.ax_len, tx.w_last), UVM_LOW)

        // Send to driver
        start_item(tx);
        assert(tx.randomize());
        finish_item(tx);
      end
    end

    `uvm_info("SEQ_WLST", "WLAST mismatch sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_WLAST_MISMATCH_SEQ_SV