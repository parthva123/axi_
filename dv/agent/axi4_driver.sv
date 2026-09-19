// axi4_driver.sv
// File        : axi4_driver.sv
// Description : UVM driver for the AXI4 slave testbench.
//               All channel transactions arrive at the driver,
//               are stored into individual per-channel queues,
//               driven pin-level to the DUT via the virtual
//               interface, and then passed to the scoreboard
//               via an analysis port. Supports withholding
//               BREADY (TC-014) and RREADY (TC-015).
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_DRIVER_SV
`define AXI4_DRIVER_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"

class axi4_driver extends uvm_driver #(axi4_seq_item);

  // -----------------------------------------------------------------------
  // Virtual interface handle
  // -----------------------------------------------------------------------
  virtual axi4_if vif;

  // -----------------------------------------------------------------------
  // Config handle
  // -----------------------------------------------------------------------
  axi4_agent_config cfg;

  // -----------------------------------------------------------------------
  // Per-channel transaction queues
  //   write_tx_q  — all write transactions driven to the DUT
  //   read_tx_q   — all read transactions driven to the DUT
  // -----------------------------------------------------------------------
  typedef queue of axi4_seq_item write_tx_q_t;
  typedef queue of axi4_seq_item read_tx_q_t;

  write_tx_q_t  write_tx_q;
  read_tx_q_t   read_tx_q;

  // -----------------------------------------------------------------------
  // Analysis port: pushes completed transactions to scoreboard
  // -----------------------------------------------------------------------
  uvm_analysis #(axi4_seq_item) analysis_port;

  // -----------------------------------------------------------------------
  // UVM factory registration
  // -----------------------------------------------------------------------
  `uvm_component_utils(axi4_driver)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi4_driver", uvm_component parent);
    super.new(name, parent);
    write_tx_q = new;
    read_tx_q  = new;
  endfunction

  // -----------------------------------------------------------------------
  // Build phase: get config, get vif, create analysis port
  // -----------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface must be set for axi4_driver")
    if (!uvm_config_db#(axi4_agent_config)::get(this, "", "cfg", cfg)) begin
      cfg = axi4_agent_config::type_id::create("cfg");
      `uvm_info("DRV", "Using default config", UVM_MEDIUM)
    end
    analysis_port = new("analysis_port", this);
    `uvm_info("DRV", "Driver built with per-channel queues + analysis_port", UVM_MEDIUM)
  endfunction

  // -----------------------------------------------------------------------
  // Run phase: fork write and read channel drivers
  // -----------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    fork
      drive_write_channel();
      drive_read_channel();
    join
  endtask

  // -----------------------------------------------------------------------
  // Write channel driver: handles AW + W + B handshake
  //   1. Get item from sequencer
  //   2. Store in write_tx_q
  //   3. Drive pin-level to DUT
  //   4. Push completed tx to scoreboard via analysis_port
  // -----------------------------------------------------------------------
  virtual task drive_write_channel();
    axi4_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      if (!req.is_write) begin
        seq_item_port.item_done();
        continue;
      end

      // --- Store in write queue ---
      write_tx_q.push_back(req);
      `uvm_info("DRV_W_Q", $sformatf(
        "Stored in write_tx_q[%0d]: addr=0x%0h id=0x%0h len=%0d",
        write_tx_q.size()-1, req.ax_addr, req.ax_id, req.ax_len), UVM_LOW)

      `uvm_info("DRV_W", $sformatf(
        "Driving WRITE pin-level: addr=0x%0h id=0x%0h len=%0d size=%0d burst=%s wstrb=0x%0h",
        req.ax_addr, req.ax_id, req.ax_len, req.ax_size, req.burst_name(), req.w_strb), UVM_MEDIUM)

      // --- Drive AW channel ---
      drive_aw(req);

      // --- Drive W channel burst ---
      drive_w_burst(req);

      // --- Drive B channel (withhold BREADY if configured) ---
      drive_b_channel(req);

      // --- Push to scoreboard via analysis_port ---
      analysis_port.write(req);

      `uvm_info("DRV_W", $sformatf(
        "WRITE complete: BID=0x%0h BRESP=%0d -> scoreboard",
        req.b_id, req.b_resp), UVM_MEDIUM)

      seq_item_port.item_done(req);
    end
  endtask

  // -----------------------------------------------------------------------
  // Read channel driver: handles AR + R handshake
  //   1. Get item from sequencer
  //   2. Store in read_tx_q
  //   3. Drive pin-level to DUT
  //   4. Push completed tx to scoreboard via analysis_port
  // -----------------------------------------------------------------------
  virtual task drive_read_channel();
    axi4_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      if (req.is_write) begin
        seq_item_port.item_done();
        continue;
      end

      // --- Store in read queue ---
      read_tx_q.push_back(req);
      `uvm_info("DRV_R_Q", $sformatf(
        "Stored in read_tx_q[%0d]: addr=0x%0h id=0x%0h len=%0d",
        read_tx_q.size()-1, req.ax_addr, req.ax_id, req.ax_len), UVM_LOW)

      `uvm_info("DRV_R", $sformatf(
        "Driving READ pin-level: addr=0x%0h id=0x%0h len=%0d size=%0d burst=%s",
        req.ax_addr, req.ax_id, req.ax_len, req.ax_size, req.burst_name()), UVM_MEDIUM)

      // --- Drive AR channel ---
      drive_ar(req);

      // --- Drive R channel burst (withhold RREADY if configured) ---
      drive_r_burst(req);

      // --- Push to scoreboard via analysis_port ---
      analysis_port.write(req);

      `uvm_info("DRV_R", $sformatf(
        "READ complete: RID=0x%0h -> scoreboard", req.r_id), UVM_MEDIUM)

      seq_item_port.item_done(req);
    end
  endtask

  // -----------------------------------------------------------------------
  // AW address channel handshake (pin-level to DUT)
  // -----------------------------------------------------------------------
  virtual task drive_aw(axi4_seq_item req);
    // Drive AW channel to DUT pins
    vif.driver_cb.S_AXI_AWID    <= req.ax_id;
    vif.driver_cb.S_AXI_AWADDR  <= req.ax_addr;
    vif.driver_cb.S_AXI_AWLEN   <= req.ax_len;
    vif.driver_cb.S_AXI_AWSIZE  <= req.ax_size;
    vif.driver_cb.S_AXI_AWBURST <= req.ax_burst;
    vif.driver_cb.S_AXI_AWLOCK  <= req.ax_lock;
    vif.driver_cb.S_AXI_AWCACHE <= req.ax_cache;
    vif.driver_cb.S_AXI_AWPROT  <= req.ax_prot;
    vif.driver_cb.S_AXI_AWQOS   <= req.ax_qos;
    vif.driver_cb.S_AXI_AWVALID <= 1'b1;

    // Wait for AWREADY (DUT pin-level response)
    @(vif.driver_cb.S_AXI_AWREADY);
    vif.driver_cb.S_AXI_AWVALID <= 1'b0;

    // Capture AWID from B channel for later comparison
    req.b_id = vif.monitor_cb.S_AXI_BID;
    req.w_valid_ok = 1;
    `uvm_info("DRV_AW", $sformatf("AW accepted at DUT pin"), UVM_LOW)
  endtask

  // -----------------------------------------------------------------------
  // W channel burst: drives data beats (pin-level)
  // -----------------------------------------------------------------------
  virtual task drive_w_burst(axi4_seq_item req);
    int num_beats = req.get_num_beats();
    int i;

    for (i = 0; i < num_beats; i++) begin
      // Drive W channel to DUT pins
      vif.driver_cb.S_AXI_WDATA <= req.w_data;
      vif.driver_cb.S_AXI_WSTRB <= req.w_strb;
      vif.driver_cb.S_AXI_WLAST <= (i == num_beats - 1);
      vif.driver_cb.S_AXI_WVALID <= 1'b1;

      // Wait for WREADY (DUT pin-level response)
      @(vif.driver_cb.S_AXI_WREADY);
      vif.driver_cb.S_AXI_WVALID <= 1'b0;

      // Track current beat for scoreboard
      req.current_beat = i;
      `uvm_info("DRV_W", $sformatf("W beat %0d accepted at DUT pin", i), UVM_LOW)
    end
  endtask

  // -----------------------------------------------------------------------
  // B channel: optionally withhold BREADY (TC-014)
  // -----------------------------------------------------------------------
  virtual task drive_b_channel(axi4_seq_item req);
    // Wait for BVALID from DUT
    @(vif.driver_cb.S_AXI_BVALID);

    if (cfg.withhold_bready) begin
      // TC-014: Master withholds BREADY at pin level
      vif.driver_cb.S_AXI_BREADY <= 1'b0;
      `uvm_info("DRV_B", "Withholding BREADY (TC-014) at pin level", UVM_MEDIUM)
      repeat(5) @(posedge vif.S_AXI_ACLK);
    end

    // Accept response at pin level
    vif.driver_cb.S_AXI_BREADY <= 1'b1;
    @(posedge vif.driver_cb.S_AXI_BVALID && posedge vif.driver_cb.S_AXI_BREADY);
    vif.driver_cb.S_AXI_BREADY <= 1'b0;

    // Capture response for scoreboard
    req.b_resp     = vif.monitor_cb.S_AXI_BRESP;
    req.b_valid_ok = 1;
    `uvm_info("DRV_B", $sformatf("B accepted: BRESP=%0d", req.b_resp), UVM_LOW)
  endtask

  // -----------------------------------------------------------------------
  // AR address channel handshake (pin-level to DUT)
  // -----------------------------------------------------------------------
  virtual task drive_ar(axi4_seq_item req);
    // Drive AR channel to DUT pins
    vif.driver_cb.S_AXI_ARID    <= req.ax_id;
    vif.driver_cb.S_AXI_ARADDR  <= req.ax_addr;
    vif.driver_cb.S_AXI_ARLEN   <= req.ax_len;
    vif.driver_cb.S_AXI_ARSIZE  <= req.ax_size;
    vif.driver_cb.S_AXI_ARBURST <= req.ax_burst;
    vif.driver_cb.S_AXI_ARLOCK  <= req.ax_lock;
    vif.driver_cb.S_AXI_ARCACHE <= req.ax_cache;
    vif.driver_cb.S_AXI_ARPROT  <= req.ax_prot;
    vif.driver_cb.S_AXI_ARQOS   <= req.ax_qos;
    vif.driver_cb.S_AXI_ARVALID <= 1'b1;

    // Wait for ARREADY (DUT pin-level response)
    @(vif.driver_cb.S_AXI_ARREADY);
    vif.driver_cb.S_AXI_ARVALID <= 1'b0;

    req.r_id = vif.monitor_cb.S_AXI_RID;
    req.r_valid_ok = 1;
    `uvm_info("DRV_AR", $sformatf("AR accepted at DUT pin"), UVM_LOW)
  endtask

  // -----------------------------------------------------------------------
  // R channel burst: drives read beats (pin-level)
  //   Withhold RREADY if configured (TC-015)
  // -----------------------------------------------------------------------
  virtual task drive_r_burst(axi4_seq_item req);
    int num_beats = req.get_num_beats();
    int i;

    for (i = 0; i < num_beats; i++) begin
      // Capture expected R data from DUT pin-level
      req.r_data = vif.monitor_cb.S_AXI_RDATA;
      req.r_last = vif.monitor_cb.S_AXI_RLAST;
      req.r_resp = vif.monitor_cb.S_AXI_RRESP;
      req.r_id    = vif.monitor_cb.S_AXI_RID;

      // Optionally withhold RREADY (TC-015)
      if (cfg.withhold_rready && (i == 0)) begin
        vif.driver_cb.S_AXI_RREADY <= 1'b0;
        `uvm_info("DRV_R", "Withholding RREADY (TC-015) at pin level", UVM_MEDIUM)
        repeat(5) @(posedge vif.S_AXI_ACLK);
      end

      // Accept read beat at pin level
      vif.driver_cb.S_AXI_RREADY <= 1'b1;

      // Wait for RVALID to deassert (final beat accepted)
      @(posedge vif.driver_cb.S_AXI_RVALID);
      @(posedge vif.driver_cb.S_AXI_RVALID && posedge vif.driver_cb.S_AXI_RLAST
         && posedge vif.driver_cb.S_AXI_RREADY);

      vif.driver_cb.S_AXI_RREADY <= 1'b0;
      req.r_valid_ok = 1;
      `uvm_info("DRV_R", $sformatf("R beat %0d accepted: RLAST=%0d", i, vif.monitor_cb.S_AXI_RLAST), UVM_LOW)
    end
  endtask

endclass

`endif // AXI4_DRIVER_SV