// axi4_defines.svh
// File        : axi4_defines.svh
// Description : Central width/depth/timing constants for the AXI4 slave TB.
//               All magic numbers, widths, depths, and timeouts live here.
//               Changing C_S_AXI_DATA_WIDTH to 64 requires edits ONLY in this file.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0
//
// Guard each individual `define so a test can override a knob via +define+
// without triggering a redefinition warning.

`ifndef AXI4_DEFINES_SVH
`define AXI4_DEFINES_SVH

  // -----------------------------------------------------------------------
  // DUT parameter equivalents (must match axi4_slave.v parameters)
  // -----------------------------------------------------------------------
  `ifndef C_S_AXI_ID_WIDTH
    `define C_S_AXI_ID_WIDTH      4
  `endif

  `ifndef C_S_AXI_ADDR_WIDTH
    `define C_S_AXI_ADDR_WIDTH    32
  `endif

  `ifndef C_S_AXI_DATA_WIDTH
    `define C_S_AXI_DATA_WIDTH    32
  `endif

  `ifndef C_S_AXI_MEM_DEPTH
    `define C_S_AXI_MEM_DEPTH     1024
  `endif

  // Derived constants
  `ifndef C_S_AXI_STRB_WIDTH
    `define C_S_AXI_STRB_WIDTH    (`C_S_AXI_DATA_WIDTH/8)
  `endif

  `ifndef ADDR_LSB
    `define ADDR_LSB              $clog2(`C_S_AXI_STRB_WIDTH)
  `endif

  `ifndef MEM_ADDR_BITS
    `define MEM_ADDR_BITS         $clog2(`C_S_AXI_MEM_DEPTH)
  `endif

  // AXI4 burst type encoding
  `ifndef BURST_FIXED
    `define BURST_FIXED           2'b00
  `endif
  `ifndef BURST_INCR
    `define BURST_INCR            2'b01
  `endif
  `ifndef BURST_WRAP
    `define BURST_WRAP            2'b10
  `endif
  `ifndef BURST_RESERVED
    `define BURST_RESERVED        2'b11
  `endif

  // AXI4 response encoding
  `ifndef RESP_OKAY
    `define RESP_OKAY             2'b00
  `endif
  `ifndef RESP_EXOKAY
    `define RESP_EXOKAY           2'b01
  `endif
  `ifndef RESP_SLVERR
    `define RESP_SLVERR           2'b10
  `endif
  `ifndef RESP_DECERR
    `define RESP_DECERR           2'b11
  `endif

  // Timing / timeouts (in clock cycles)
  `ifndef TC_SETUP
    `define TC_SETUP              10
  `endif
  `ifndef TC_HOLD
    `define TC_HOLD               5
  `endif
  `ifndef TC_BURST_TIMEOUT
    `define TC_BURST_TIMEOUT      1024
  `endif

  // Memory block sizes for Layer-1 sweep (TC-M001..TC-M200)
  `ifndef SWEEP_BLOCK_SMALL
    `define SWEEP_BLOCK_SMALL     5   // words per small block (TC-M001..M176)
  `endif
  `ifndef SWEEP_BLOCK_SMALL_COUNT
    `define SWEEP_BLOCK_SMALL_COUNT 176
  `endif
  `ifndef SWEEP_BLOCK_LARGE
    `define SWEEP_BLOCK_LARGE     6   // words per large block (TC-M177..M200)
  `endif
  `ifndef SWEEP_BLOCK_LARGE_COUNT
    `define SWEEP_BLOCK_LARGE_COUNT 24
  `endif

`endif // AXI4_DEFINES_SVH