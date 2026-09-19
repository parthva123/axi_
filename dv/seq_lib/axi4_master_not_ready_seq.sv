// axi4_master_not_ready_seq.sv
// File        : axi4_master_not_ready_seq.sv
// Description : Master not-ready sequence for AXI4 slave testbench.
//               Tests TC-014 (withhold BREADY) and TC-015 (withhold RREADY)
//               by configuring the driver to withhold handshakes.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_MASTER_NOT_READY_SEQ_SV
`define AXI4_MASTER_NOT_READY_SEQ_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_master_not_ready_seq extends uvm_sequence #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Configuration: which handshake to withhold
  // -----------------------------------------------------------------------
  rand bit withhold_bready;   // TC-014
  rand bit withhold_rready;   // TC-015

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_sequence_utils(axi4_master_not_ready_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_master_not_ready_seq");
    super.new(name);
    withhold_bready = 1'b0;
    withhold_rready = 1'b0;
  endfunction

  // -----------------------------------------------------------------------
  // Pre-body: configure driver for withholding
  // -----------------------------------------------------------------------
  virtual task pre_body();
    axi4_agent_config cfg;

    // Get agent config from DB and set withholding flags
    if (uvm_config_db#(axi4_agent_config)::get(this, "", "cfg", cfg)) begin
      cfg.withhold_bready = withhold_bready;
      cfg.withhold_rready = withhold_rready;
      uvm_config_db#(axi4_agent_config)::set(this, "", "cfg", cfg);
      `uvm_info("SEQ_MNR", $sformatf(
        "Configured withholding: bready=%0d rready=%0d",
        withhold_bready, withhold_rready), UVM_MEDIUM)
    end else begin
      `uvm_warning("SEQ_MNR", "Agent config not found in DB")
    end
  endtask

  // -----------------------------------------------------------------------
  // Body: send transactions with withheld handshakes
  // -----------------------------------------------------------------------
  virtual task body();
    axi4_seq_item tx;

    `uvm_info("SEQ_MNR", "Starting master not-ready sequence", UVM_MEDIUM)

    // Test write channel with withheld BREADY (TC-014)
    if (withhold_bready) begin
      tx = axi4_seq_item::type_id::create("tx_bready");
      assert(tx.randomize() with {
        is_write == 1'b1;
        ax_id < 16;
        ax_addr < (1 << 30);
        ax_len < 4;
        ax_size < 8;
        ax_burst inside {`BURST_FIXED, `BURST_INCR, `BURST_WRAP};
      });
      tx.w_strb = (~0) << (tx.ax_size[1:0]);
      tx.w_last = 1'b1;

      `uvm_info("SEQ_MNR", "Sending write with withheld BREADY (TC-014)", UVM_LOW)

      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end

    // Test read channel with withheld RREADY (TC-015)
    if (withhold_rready) begin
      tx = axi4_seq_item::type_id::create("tx_rready");
      assert(tx.randomize() with {
        is_write == 1'b0;
        ax_id < 16;
        ax_addr < (1 << 30);
        ax_len < 4;
        ax_size < 8;
        ax_burst inside {`BURST_FIXED, `BURST_INCR, `BURST_WRAP};
      });

      `uvm_info("SEQ_MNR", "Sending read with withheld RREADY (TC-015)", UVM_LOW)

      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end

    // Also test normal operations (no withholding) for comparison
    if (!withhold_bready && !withhold_rready) begin
      // Normal write and read
      for (int i = 0; i < 5; i++) begin
        // Write
        tx = axi4_seq_item::type_id::create($sformatf("tx_w%0d", i));
        assert(tx.randomize() with {
          is_write == 1'b1; ax_id < 16; ax_addr < (1 << 30);
        });
        tx.w_strb = 4'hF;
        tx.w_last = 1'b1;
        start_item(tx);
        assert(tx.randomize());
        finish_item(tx);

        // Read
        tx = axi4_seq_item::type_id::create($sformatf("tx_r%0d", i));
        assert(tx.randomize() with {
          is_write == 1'b0; ax_id < 16; ax_addr < (1 << 30);
        });
        start_item(tx);
        assert(tx.randomize());
        finish_item(tx);
      end
    end

    `uvm_info("SEQ_MNR", "Master not-ready sequence complete", UVM_MEDIUM)
  endtask

endclass

`endif // AXI4_MASTER_NOT_READY_SEQ_SV