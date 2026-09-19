// axi4_typedefs.svh
// File        : axi4_typedefs.svh
// Description : Type definitions used across the AXI4 slave UVM TB.
//               Enumerations for burst types, responses, transfer
//               sizes, byte strobes, and transaction categories.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_TYPEDEFS_SVH
`define AXI4_TYPEDEFS_SVH

  // -----------------------------------------------------------------------
  // Burst type enumeration
  // -----------------------------------------------------------------------
  typedef enum logic [1:0] {
    BURST_FIXED  = 2'b00,
    BURST_INCR   = 2'b01,
    BURST_WRAP   = 2'b10,
    BURST_RESERVED = 2'b11
  } burst_type_e;

  // -----------------------------------------------------------------------
  // AXI4 response enumeration
  // -----------------------------------------------------------------------
  typedef enum logic [1:0] {
    RESP_OKAY   = 2'b00,
    RESP_EXOKAY = 2'b01,
    RESP_SLVERR = 2'b10,
    RESP_DECERR = 2'b11
  } resp_e;

  // -----------------------------------------------------------------------
  // Transfer size encoding (AxSIZE field)
  // -----------------------------------------------------------------------
  typedef enum logic [2:0] {
    SIZE_1BIT  = 3'b000,   // 1 byte
    SIZE_2BIT  = 3'b001,   // 2 bytes
    SIZE_4BIT  = 3'b010,   // 4 bytes
    SIZE_8BIT  = 3'b011,   // 8 bytes
    SIZE_16BIT = 3'b100,   // 16 bytes
    SIZE_32BIT = 3'b101,   // 32 bytes
    SIZE_64BIT = 3'b110,   // 64 bytes
    SIZE_128BIT= 3'b111    // 128 bytes (reserved for this params)
  } axsize_e;

  // -----------------------------------------------------------------------
  // Byte strobe encoding (WSTRB)
  // -----------------------------------------------------------------------
  typedef enum logic [3:0] {
    STRB_NONE  = 4'b0000,
    STRB_LANE0 = 4'b0001,
    STRB_LANE1 = 4'b0010,
    STRB_LANE2 = 4'b0100,
    STRB_LANE3 = 4'b1000,
    STRB_ALL   = 4'b1111
  } strb_e;

  // -----------------------------------------------------------------------
  // Concurrency category (for coverage)
  // -----------------------------------------------------------------------
  typedef enum logic [2:0] {
    CONC_IDLE       = 3'b000,
    CONC_READ_ONLY  = 3'b001,
    CONC_WRITE_ONLY = 3'b010,
    CONC_INTERLEAVED= 3'b011
  } concurrency_e;

  // -----------------------------------------------------------------------
  // AWLEN range categories (for coverage)
  // -----------------------------------------------------------------------
  typedef enum logic [2:0] {
    AWLEN_SHORT  = 3'b000,  // 1-4 beats
    AWLEN_MEDIUM = 3'b001,  // 5-8 beats
    AWLEN_LONG   = 3'b010,  // 9-16 beats
    AWLEN_MAX    = 3'b011    // 17-256 beats
  } awlen_range_e;

  // -----------------------------------------------------------------------
  // WLAST timing category (for coverage)
  // -----------------------------------------------------------------------
  typedef enum logic [1:0] {
    WLAST_CORRECT  = 2'b00,
    WLAST_MISMATCH = 2'b01
  } wlast_timing_e;

  // -----------------------------------------------------------------------
  // Read/Write order category (for coverage)
  // -----------------------------------------------------------------------
  typedef enum logic [2:0] {
    ORDER_R_AFTER_W = 3'b000,
    ORDER_W_AFTER_R = 3'b001,
    ORDER_CONCURRENT = 3'b010
  } rw_order_e;

`endif // AXI4_TYPEDEFS_SVH