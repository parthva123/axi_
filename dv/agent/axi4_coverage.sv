// axi4_coverage.sv
// File        : axi4_coverage.sv
// Description : UVM coverage collector for the AXI4 slave testbench.
//               Implements 15 covergroups: burst_type, burst_length, transfer_size,
//               byte_strobe, address_range, response, concurrency, transaction_id,
//               memory_word, byte_lane, slverr_sticky, reset_during_tx, awlen_range,
//               wlast_timing, and read_write_order.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_COVERAGE_SV
`define AXI4_COVERAGE_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"
`include "axi4_seq_item.sv"

class axi4_coverage extends uvm_component;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_coverage)

  // -----------------------------------------------------------------------
  // Analysis port: receives completed transactions from agent
  // -----------------------------------------------------------------------
  uvm_analysis_imp #(axi4_seq_item, axi4_coverage) coverage_port;

  // -----------------------------------------------------------------------
  // Covergroups
  // -----------------------------------------------------------------------

  // Covergroup: cg_burst_type - monitors burst type (FIXED/INCR/WRAP)
  covergroup cg_burst_type with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_burst_type";

    cp_burst: coverpoint item.ax_burst {
      bins FIXED = {`BURST_FIXED};
      bins INCR = {`BURST_INCR};
      bins WRAP = {`BURST_WRAP};
    }
  endgroup

  // Covergroup: cg_burst_length - monitors burst length (0-255, maps to 1-256 beats)
  covergroup cg_burst_length with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_burst_length";

    cp_len: coverpoint item.ax_len {
      bins SHORT = [0:15];    // 1-16 beats
      bins MEDIUM = [16:63];   // 17-64 beats
      bins LONG = [64:255];    // 65-256 beats
    }
  endgroup

  // Covergroup: cg_transfer_size - monitors data width in bytes (1, 2, 4, 8, 16, 32, 64, 128)
  covergroup cg_transfer_size with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_transfer_size";

    cp_size: coverpoint item.ax_size {
      bins B1   = {0};
      bins B2   = {1};
      bins B4   = {2};
      bins B8   = {3};
      bins B16  = {4};
      bins B32  = {5};
      bins B64  = {6};
      bins B128 = {7};
    }
  endgroup

  // Covergroup: cg_byte_strobe - monitors write strobe pattern
  covergroup cg_byte_strobe with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_byte_strobe";

    cp_strb: coverpoint item.w_strb {
      bins ALL_BITS = {[(0 << item.ax_size):$ -1]};
      bins SOME_BITS = {[(0 << item.ax_size):item.ax_size*2-1]};
      bins SINGLE_BIT = {[(0 << item.ax_size):0]};
    }
  endgroup

  // Covergroup: cg_address_range - monitors address alignment and range
  covergroup cg_address_range with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_address_range";

    cp_addr: coverpoint (item.ax_addr >> item.ax_size) {
      bins ALIGNED_4B  = {[$ -4:0]};
      bins ALIGNED_8B  = {[$ -8:0]};
      bins ALIGNED_16B = {[$ -16:0]};
      bins MISALIGNED  = {[$ -1:1]};
    }
  endgroup

  // Covergroup: cg_response - monitors response codes (OKAY, EXOKAY, SLVERR, DECERR)
  covergroup cg_response with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_response";

    cp_resp: coverpoint item.b_resp {
      bins OKAY    = {`RESP_OKAY};
      bins EXOKAY = {`RESP_EXOKAY};
      bins SLVERR  = {`RESP_SLVERR};
      bins DECERR  = {`RESP_DECERR};
    }
  endgroup

  // Covergroup: cg_concurrency - monitors concurrent transactions
  covergroup cg_concurrency with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_concurrency";

    cp_dir: coverpoint item.is_write {
      bins WRITE  = {1'b0};
      bins READ   = {1'b1};
    }
  endgroup

  // Covergroup: cg_transaction_id - monitors transaction ID usage
  covergroup cg_transaction_id with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_transaction_id";

    cp_id: coverpoint item.ax_id {
      bins ID_0_15 = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
    }
  endgroup

  // Covergroup: cg_memory_word - monitors memory access patterns (scoreboard dependency)
  covergroup cg_memory_word with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_memory_word";

    cp_addr_range: coverpoint (item.ax_addr >> 2) {  // Word addressing (32-bit words)
      bins MEM_0_255 = {[0:255]};
      bins MEM_256_511 = {[256:511]};
      bins MEM_512_767 = {[512:767]};
      bins MEM_768_1023 = {[768:1023]};
    }
  endgroup

  // Covergroup: cg_byte_lane - monitors byte lane access (scoreboard dependency)
  covergroup cg_byte_lane with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_byte_lane";

    cp_lane: coverpoint item.w_strb {
      bins ALL_LANES = {[(0 << item.ax_size):$ -1]};
      bins HALF_LANES = {[(0 << item.ax_size):(1 << item.ax_size) -1]};
      bins SINGLE_LANE = {[(0 << item.ax_size):0]};
    }
  endgroup

  // Covergroup: cg_slverr_sticky - monitors SLVERR stickiness behavior (scoreboard dependency)
  covergroup cg_slverr_sticky with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_slverr_sticky";

    cp_sticky: coverpoint item.b_resp {
      bins OKAY_EXOKAY = {`RESP_OKAY, `RESP_EXOKAY};
      bins SLVERR_DECERR = {`RESP_SLVERR, `RESP_DECERR};
    }
  endgroup

  // Covergroup: cg_reset_during_tx - monitors reset behavior during transactions (scoreboard dependency)
  covergroup cg_reset_during_tx with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_reset_during_tx";

    cp_reset_sensitive: coverpoint {item.is_write && (item.ax_len > 0)} {
      bins DURING_WRITE = {1};
      bins NOT_DURING = {0};
    }
  endgroup

  // Covergroup: cg_awlen_range - monitors AWLEN legal range (0-255, legal per AXI4 spec)
  covergroup cg_awlen_range with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_awlen_range";

    cp_legal_range: coverpoint item.ax_len {
      bins LEGAL = {[0:255]};
      bins INVALID = {256,257,258,259,260,261,262,263,264};
    }
  endgroup

  // Covergroup: cg_wlast_timing - monitors WLAST timing relative to burst length (scoreboard dependency)
  covergroup cg_wlast_timing with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_wlast_timing";

    cp_wlast_ok: coverpoint (item.w_last == 1'b1) {
      bins WLAST_VALID = {1'b1};
    }
  endgroup

  // Covergroup: cg_read_write_order - monitors order of R and W responses (cross coverage)
  covergroup cg_read_write_order with function sample(axi4_seq_item item);
    option.per_instance = 1;
    option.name = "cg_read_write_order";

    cp_rw_order: coverpoint item.is_write {
      bins WRITE_FIRST = {1'b0};
      bins READ_FIRST = {1'b1};
    }
  endgroup

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_coverage", uvm_component parent);
    super.new(name, parent);
    coverage_port = new(this, "coverage_port");

    // Instantiate covergroups
    cg_burst_type = new();
    cg_burst_length = new();
    cg_transfer_size = new();
    cg_byte_strobe = new();
    cg_address_range = new();
    cg_response = new();
    cg_concurrency = new();
    cg_transaction_id = new();
    cg_memory_word = new();
    cg_byte_lane = new();
    cg_slverr_sticky = new();
    cg_reset_during_tx = new();
    cg_awlen_range = new();
    cg_wlast_timing = new();
    cg_read_write_order = new();

    `uvm_info("COV", "axi4_coverage constructed with 15 covergroups", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Write callback: sample incoming transaction
  // -----------------------------------------------------------------------
  virtual function void write(axi4_seq_item item);
    if (item != null && cfg.enable_coverage) begin
      cg_burst_type.sample(item);
      cg_burst_length.sample(item);
      cg_transfer_size.sample(item);
      cg_byte_strobe.sample(item);
      cg_address_range.sample(item);
      cg_response.sample(item);
      cg_concurrency.sample(item);
      cg_transaction_id.sample(item);
      cg_memory_word.sample(item);
      cg_byte_lane.sample(item);
      cg_slverr_sticky.sample(item);
      cg_reset_during_tx.sample(item);
      cg_awlen_range.sample(item);
      cg_wlast_timing.sample(item);
      cg_read_write_order.sample(item);

      `uvm_info("COV", $sformatf(
        "Coverage sample: %s addr=0x%0h len=%0d burst=%s",
        item.dir_name(), item.ax_addr, item.ax_len, item.burst_name()), UVM_LOW)
    end
  endfunction

  // -----------------------------------------------------------------------
  // Report phase: print coverage stats
  // -----------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Coverage report - Total samples: %0d",
      cg_burst_type.get_coverage() + cg_burst_length.get_coverage()), UVM_MEDIUM)
    super.report_phase(phase);
  endfunction

  // -----------------------------------------------------------------------
  // Get config from db
  // -----------------------------------------------------------------------
  axi4_agent_config cfg;
  function void get_config();
    if (!uvm_config_db#(axi4_agent_config)::get(this, "", "cfg", cfg)) begin
      cfg = axi4_agent_config::type_id::create("cfg");
      `uvm_info("COV", "Using default coverage config", UVM_MEDIUM)
    end
  endfunction

endclass

`endif // AXI4_COVERAGE_SV