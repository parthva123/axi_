// axi4_scoreboard.sv
// File        : axi4_scoreboard.sv
// Description : UVM scoreboard for the AXI4 slave testbench.
//               Receives transactions from driver and monitor,
//               uses axi4_ref_model for expected behavior,
//               compares predicted vs actual responses,
//               tracks SLVERR stickiness.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_SCOREBOARD_SV
`define AXI4_SCOREBOARD_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"
`include "axi4_ref_model.sv"

class axi4_scoreboard extends uvm_component;

  // -----------------------------------------------------------------------
  // Reference model instance
  // -----------------------------------------------------------------------
  axi4_ref_model ref_model;

  // -----------------------------------------------------------------------
  // Analysis imports: receive transactions from driver and monitor
  // -----------------------------------------------------------------------
  uvm_analysis_imp #(axi4_seq_item, axi4_scoreboard) analysis_export;

  // -----------------------------------------------------------------------
  // Transaction queues for matching
  // -----------------------------------------------------------------------
  axi4_seq_item write_queue[$];
  axi4_seq_item read_queue[$];

  // -----------------------------------------------------------------------
  // Scoreboard statistics
  // -----------------------------------------------------------------------
  int unsigned match_count = 0;
  int unsigned mismatch_count = 0;
  int unsigned error_count = 0;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_scoreboard)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_scoreboard", uvm_component parent);
    super.new(name, parent);
    analysis_export = new(this, "analysis_export");
    `uvm_info("SCB", "axi4_scoreboard constructed", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: create reference model
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ref_model = axi4_ref_model::type_id::create("ref_model", this);
    `uvm_info("SCB", "Reference model created", UVM_LOW)
  endfunction

  // -----------------------------------------------------------------------
  // Write callback: receive transactions from driver/monitor
  // -----------------------------------------------------------------------
  virtual function void write(axi4_seq_item tx);
    if (tx == null) begin
      `uvm_warning("SCB", "Received null transaction")
      return;
    end

    if (tx.is_write) begin
      process_write_tx(tx);
    end else begin
      process_read_tx(tx);
    end
  endfunction

  // -----------------------------------------------------------------------
  // Process a write transaction from driver
  //   - Predict B response using ref_model
  //   - Compare predicted vs actual B response
  //   - Store in write_queue for later matching
  // -----------------------------------------------------------------------
  virtual function void process_write_tx(axi4_seq_item tx);
    bit [1:0] predicted_b_resp = ref_model.predict_b_resp(tx);

    // Store in write queue
    write_queue.push_back(tx);

    // Compare B response
    if (predicted_b_resp != tx.b_resp) begin
      `uvm_error("SCB_W", $sformatf(
        "WRITE B response mismatch: addr=0x%0h id=0x%0h predicted=%0d actual=%0d",
        tx.ax_addr, tx.ax_id, predicted_b_resp, tx.b_resp))
      mismatch_count++;
    end else begin
      `uvm_info("SCB_W", $sformatf(
        "WRITE B response match: addr=0x%0h id=0x%0h resp=%0d",
        tx.ax_addr, tx.ax_id, tx.b_resp), UVM_LOW)
      match_count++;
    end

    // Process write in ref_model (store data in memory)
    ref_model.process_write(tx);
  endfunction

  // -----------------------------------------------------------------------
  // Process a read transaction from monitor
  //   - Predict R data using ref_model
  //   - Compare predicted vs actual R data
  //   - Store in read_queue for later matching
  // -----------------------------------------------------------------------
  virtual function void process_read_tx(axi4_seq_item tx);
    bit [31:0] predicted_r_data = ref_model.predict_r_data(tx);
    bit [1:0]  predicted_r_resp = ref_model.predict_r_resp(tx);

    // Store in read queue
    read_queue.push_back(tx);

    // Compare R data
    if (predicted_r_data !== tx.r_data) begin
      `uvm_error("SCB_R", $sformatf(
        "READ R data mismatch: addr=0x%0h id=0x%0h predicted=0x%0h actual=0x%0h",
        tx.ax_addr, tx.ax_id, predicted_r_data, tx.r_data))
      mismatch_count++;
    end else begin
      `uvm_info("SCB_R", $sformatf(
        "READ R data match: addr=0x%0h id=0x%0h data=0x%0h",
        tx.ax_addr, tx.ax_id, tx.r_data), UVM_LOW)
      match_count++;
    end

    // Compare R response
    if (predicted_r_resp != tx.r_resp) begin
      `uvm_error("SCB_R", $sformatf(
        "READ R response mismatch: addr=0x%0h id=0x%0h predicted=%0d actual=%0d",
        tx.ax_addr, tx.ax_id, predicted_r_resp, tx.r_resp))
      mismatch_count++;
    end

    // Process read in ref_model
    ref_model.process_read(tx);
  endfunction

  // -----------------------------------------------------------------------
  // Check SLVERR stickiness
  // -----------------------------------------------------------------------
  virtual function void check_slverr_sticky(axi4_seq_item tx);
    bit sticky = ref_model.get_slverr_sticky();
    if (sticky && tx.b_resp != `RESP_SLVERR) begin
      `uvm_error("SCB_STICKY", $sformatf(
        "SLVERR stickiness violation: addr=0x%0h expected SLVERR got %0d",
        tx.ax_addr, tx.b_resp))
      mismatch_count++;
    end
  endfunction

  // -----------------------------------------------------------------------
  // Report phase: print scoreboard statistics
  // -----------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf(
      "=== Scoreboard Report ===\n" +
      "  Matches:     %0d\n" +
      "  Mismatches:  %0d\n" +
      "  Errors:      %0d\n" +
      "  Write queue: %0d\n" +
      "  Read queue:  %0d",
      match_count, mismatch_count, error_count,
      write_queue.size(), read_queue.size()), UVM_LOW)
    super.report_phase(phase);
  endfunction

endclass

`endif // AXI4_SCOREBOARD_SV