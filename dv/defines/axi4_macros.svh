// axi4_macros.svh
// File        : axi4_macros.svh
// Description : AXI4 utility and checking macros used across the TB.
//               Includes burst-address calculation, byte-strobe masking,
//               range checking, and transaction-printing convenience.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_MACROS_SVH
`define AXI4_MACROS_SVH

  // -----------------------------------------------------------------------
  // Compute next address in a burst (matches DUT's next_addr function)
  // Usage:  next_addr = AXI4_NEXT_ADDR(cur_addr, burst_type, axsize, axlen)
  // -----------------------------------------------------------------------
  `define AXI4_NEXT_ADDR(cur, burst, axsize, axlen) \
    begin \
      localparam int unsigned strb_width = `C_S_AXI_STRB_WIDTH; \
      localparam int unsigned num_bytes  = (1 << axsize); \
      localparam int unsigned wrap_size  = num_bytes * ((axlen) + 1); \
      localparam int unsigned wrap_boundary = (cur) & ~(wrap_size - 1); \
      if ((burst) == 2'b10) begin // WRAP \
        localparam int unsigned incr_addr = (cur) + num_bytes; \
        if (incr_addr >= (wrap_boundary + wrap_size)) \
          next_addr = wrap_boundary; \
        else \
          next_addr = incr_addr; \
      end else begin \
        next_addr = (cur) + num_bytes; \
      end \
    end

  // -----------------------------------------------------------------------
  // Byte-strobe masking: only modify bytes where WSTRB is asserted
  // Usage:  AXI4_STRB_MASK(mem, wr_data, wstrb, mem_idx, data_width);
  // -----------------------------------------------------------------------
  `define AXI4_STRB_MASK(mem_base, wr_data, wstrb, mem_idx, dw) \
    genvar _i; \
    generate \
      for (_i = 0; _i < (dw)/8; _i = _i + 1) begin : g_strb_mask \
        if (wstrb[_i]) \
          mem_base[(mem_idx)*((dw)/8) + _i * 8 +: 8] <= wr_data[_i * 8 +: 8]; \
      end \
    endgenerate

  // -----------------------------------------------------------------------
  // Range check: is an AXI address in the valid memory window?
  // Returns 1'b1 if in range, 1'b0 if out of range.
  // Usage:  in_range = AXI4_IN_RANGE(addr);
  // -----------------------------------------------------------------------
  `define AXI4_IN_RANGE(addr) \
    ((`C_S_AXI_ADDR_WIDTH > (`ADDR_LSB + `MEM_ADDR_BITS)) ? \
        ((addr)[`C_S_AXI_ADDR_WIDTH-1:(`ADDR_LSB+`MEM_ADDR_BITS)] == 0) : \
        1'b1)

  // -----------------------------------------------------------------------
  // Shortcut assertion/report macro for UVM info/debug
  // Usage:  `AXI4_CHECK(cond, tag, verbosity)
  // -----------------------------------------------------------------------
  `define AXI4_CHECK(cond, tag, verb) \
    if (!(cond)) begin \
      `uvm_info("AXI4_CHK", $sformatf("FAIL: %s", tag), verb) \
      $error("AXI4 CHECK FAILED: %s", tag); \
    end else begin \
      `uvm_info("AXI4_CHK", $sformatf("PASS: %s", tag), verb) \
    end

  // -----------------------------------------------------------------------
  // Clamp AxLEN to legal range (0..255); used in sequence constraints
  // -----------------------------------------------------------------------
  `define AXI4_CLAMP_LEN(len) \
    ((len) > 255 ? 255 : ((len) < 0 ? 0 : (len)))

`endif // AXI4_MACROS_SVH