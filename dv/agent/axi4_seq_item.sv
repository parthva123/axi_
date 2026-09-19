// axi4_seq_item.sv
// File        : axi4_seq_item.sv
// Description : UVM sequence item representing a single AXI4
//               transaction beat. Carries all channel signals
//               plus metadata used by the driver, scoreboard,
//               monitor, and coverage.
// Author      : Verification Engineer
// Date        : 2026-09-17
// Revision    : 1.0

`ifndef AXI4_SEQ_ITEM_SV
`define AXI4_SEQ_ITEM_SV

`include "axi4_defines.svh"
`include "axi4_typedefs.svh"

class axi4_seq_item extends uvm_sequence_item;

    // -----------------------------------------------------------------------
    // Transaction direction
    // -----------------------------------------------------------------------
    typedef enum logic { WRITE = 1'b0, READ = 1'b1 } dir_e;

    // -----------------------------------------------------------------------
    // Burst and channel metadata
    // -----------------------------------------------------------------------
    rand bit [3:0]            ax_id;       // AWID / ARID
    rand bit [31:0]           ax_addr;     // AWADDR / ARADDR
    rand bit [7:0]            ax_len;      // AWLEN / ARLEN (0 = 1 beat)
    rand bit [2:0]            ax_size;     // AWSIZE / ARSIZE
    rand bit [1:0]            ax_burst;    // AWBURST / ARBURST
    rand bit                  ax_lock;     // AWLOCK / ARLOCK
    rand bit [3:0]            ax_cache;    // AWCACHE / ARCACHE
    rand bit [2:0]            ax_prot;     // AWPROT / ARPROT
    rand bit [3:0]            ax_qos;      // AWQOS / ARQOS

    // -----------------------------------------------------------------------
    // Write Data channel (valid for WRITE transactions)
    // -----------------------------------------------------------------------
    rand bit [31:0]           w_data;
    rand bit [`C_S_AXI_STRB_WIDTH-1:0] w_strb;
    rand bit                  w_last;      // WLAST

    // -----------------------------------------------------------------------
    // Transaction outcome (populated by scoreboard / reference model)
    // -----------------------------------------------------------------------
    bit [3:0]                 b_id;        // BID
    bit [1:0]                 b_resp;      // BRESP
    bit                       b_valid_ok;  // B channel accepted (BREADY high)

    bit [31:0]                r_data;      // RDATA (read response)
    bit [1:0]                 r_resp;      // RRESP
    bit                       r_last;      // RLAST
    bit                       r_valid_ok;  // R channel accepted (RREADY high)

    // -----------------------------------------------------------------------
    // Internal bookkeeping (not randomized, used by driver/monitor)
    // -----------------------------------------------------------------------
    bit                       is_write;    // 1 = write, 0 = read
    bit                       is_whitebox; // 1 = white-box override item (TC-014/015)
    bit                       withhold_bready; // TC-014: driver withholds BREADY
    bit                       withhold_rready; // TC-015: driver withholds RREADY
    int unsigned              beat_count;  // beats remaining in current burst
    int unsigned              current_beat; // current beat index in burst

    // -----------------------------------------------------------------------
    // UVM factory and field automation
    // -----------------------------------------------------------------------
    `uvm_object_utils_begin(axi4_seq_item)
        `uvm_field_int(ax_id,            UVM_DEFAULT)
        `uvm_field_int(ax_addr,          UVM_DEFAULT)
        `uvm_field_int(ax_len,           UVM_DEFAULT)
        `uvm_field_int(ax_size,          UVM_DEFAULT)
        `uvm_field_int(ax_burst,         UVM_DEFAULT)
        `uvm_field_int(ax_lock,          UVM_DEFAULT)
        `uvm_field_int(ax_cache,         UVM_DEFAULT)
        `uvm_field_int(ax_prot,          UVM_DEFAULT)
        `uvm_field_int(ax_qos,           UVM_DEFAULT)
        `uvm_field_int(w_data,           UVM_DEFAULT)
        `uvm_field_int(w_strb,           UVM_DEFAULT)
        `uvm_field_int(w_last,           UVM_DEFAULT)
        `uvm_field_int(b_id,             UVM_DEFAULT)
        `uvm_field_int(b_resp,           UVM_DEFAULT)
        `uvm_field_int(b_valid_ok,       UVM_DEFAULT)
        `uvm_field_int(r_data,           UVM_DEFAULT)
        `uvm_field_int(r_resp,           UVM_DEFAULT)
        `uvm_field_int(r_last,           UVM_DEFAULT)
        `uvm_field_int(r_valid_ok,       UVM_DEFAULT)
        `uvm_field_int(is_write,         UVM_DEFAULT)
        `uvm_field_int(is_whitebox,      UVM_DEFAULT)
        `uvm_field_int(withhold_bready,  UVM_DEFAULT)
        `uvm_field_int(withhold_rready,  UVM_DEFAULT)
        `uvm_field_int(beat_count,       UVM_DEFAULT)
        `uvm_field_int(current_beat,     UVM_DEFAULT)
    `uvm_object_utils_end

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------
    function new(string name = "axi4_seq_item");
        super.new(name);
    endfunction

    // -----------------------------------------------------------------------
    // Helper: number of beats in this transaction
    // -----------------------------------------------------------------------
    function int unsigned get_num_beats();
        return ax_len + 1;
    endfunction

    // -----------------------------------------------------------------------
    // Helper: transfer size in bytes
    // -----------------------------------------------------------------------
    function int unsigned get_transfer_size_bytes();
        return (1 << ax_size);
    endfunction

    // -----------------------------------------------------------------------
    // Helper: burst name string (for $uvm_info messages)
    // -----------------------------------------------------------------------
    function string burst_name();
        case (ax_burst)
            `BURST_FIXED: return "FIXED";
            `BURST_INCR:  return "INCR";
            `BURST_WRAP:  return "WRAP";
            `BURST_RESERVED: return "RESERVED";
            default: return "UNKNOWN";
        endcase
    endfunction

    // -----------------------------------------------------------------------
    // Helper: direction name string
    // -----------------------------------------------------------------------
    function string dir_name();
        return is_write ? "WRITE" : "READ";
    endfunction

endclass

`endif // AXI4_SEQ_ITEM_SV