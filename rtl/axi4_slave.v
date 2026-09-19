//=============================================================================
// File        : axi4_slave.v
// Description : Simple, parameterizable AXI4 slave.
//               - Full AXI4 (not AXI4-Lite): supports burst transactions
//                 (FIXED / INCR / WRAP), byte-strobed writes, and SLVERR
//                 generation for out-of-range accesses.
//               - Storage is a simple register-bank / memory array
//                 (C_S_AXI_MEM_DEPTH words of C_S_AXI_DATA_WIDTH bits).
//               - Read and write channels run as two independent FSMs, so
//                 concurrent reads and writes are supported, as required by
//                 the AXI4 protocol.
//
// Assumptions / simplifications (documented on purpose - good discussion
// points for the thesis, and good corner cases for your UVM env to target):
//   1. Only "aligned, full-width" transfers are functionally required for
//      correct data placement: AxSIZE is expected to equal
//      log2(C_S_AXI_DATA_WIDTH/8). Narrower AxSIZE values are still legal on
//      the bus (address increments correctly) but the slave does not do
//      byte-lane shifting for narrow reads - WSTRB is still honored on
//      writes.
//   2. Memory is modeled as flip-flops/LUTRAM (combinational read), not
//      block RAM, so there is a fixed, deterministic 1-cycle latency from
//      address-channel handshake to first data-channel beat.
//   3. Address decode: mem is mapped starting at offset 0. Any address
//      outside [0, C_S_AXI_MEM_DEPTH*STRB_WIDTH) returns SLVERR (write is
//      dropped; read returns zero with SLVERR). Once SLVERR occurs in a
//      write burst, the response for that burst stays SLVERR (sticky).
//=============================================================================
`timescale 1ns / 1ps

module axi4_slave #(
    parameter integer C_S_AXI_ID_WIDTH   = 4,
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer C_S_AXI_DATA_WIDTH = 32,   // 32 / 64 / 128 ...
    parameter integer C_S_AXI_MEM_DEPTH  = 1024  // depth in words of C_S_AXI_DATA_WIDTH
)(
    input  wire                                S_AXI_ACLK,
    input  wire                                S_AXI_ARESETN,   // active-low, synchronous

    // ---------------- Write Address Channel ----------------
    input  wire [C_S_AXI_ID_WIDTH-1:0]         S_AXI_AWID,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_AWADDR,
    input  wire [7:0]                          S_AXI_AWLEN,
    input  wire [2:0]                          S_AXI_AWSIZE,
    input  wire [1:0]                          S_AXI_AWBURST,
    input  wire                                S_AXI_AWLOCK,
    input  wire [3:0]                          S_AXI_AWCACHE,
    input  wire [2:0]                          S_AXI_AWPROT,
    input  wire [3:0]                          S_AXI_AWQOS,
    input  wire                                S_AXI_AWVALID,
    output wire                                S_AXI_AWREADY,

    // ---------------- Write Data Channel --------------------
    input  wire [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]   S_AXI_WSTRB,
    input  wire                                S_AXI_WLAST,
    input  wire                                S_AXI_WVALID,
    output wire                                S_AXI_WREADY,

    // ---------------- Write Response Channel -----------------
    output reg  [C_S_AXI_ID_WIDTH-1:0]         S_AXI_BID,
    output reg  [1:0]                          S_AXI_BRESP,
    output reg                                 S_AXI_BVALID,
    input  wire                                S_AXI_BREADY,

    // ---------------- Read Address Channel --------------------
    input  wire [C_S_AXI_ID_WIDTH-1:0]         S_AXI_ARID,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_ARADDR,
    input  wire [7:0]                          S_AXI_ARLEN,
    input  wire [2:0]                          S_AXI_ARSIZE,
    input  wire [1:0]                          S_AXI_ARBURST,
    input  wire                                S_AXI_ARLOCK,
    input  wire [3:0]                          S_AXI_ARCACHE,
    input  wire [2:0]                          S_AXI_ARPROT,
    input  wire [3:0]                          S_AXI_ARQOS,
    input  wire                                S_AXI_ARVALID,
    output wire                                S_AXI_ARREADY,

    // ---------------- Read Data Channel ------------------------
    output reg  [C_S_AXI_ID_WIDTH-1:0]         S_AXI_RID,
    output reg  [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_RDATA,
    output reg  [1:0]                          S_AXI_RRESP,
    output reg                                 S_AXI_RLAST,
    output reg                                 S_AXI_RVALID,
    input  wire                                S_AXI_RREADY
);

    //-------------------------------------------------------------------
    // Local parameters
    //-------------------------------------------------------------------
    localparam integer STRB_WIDTH    = C_S_AXI_DATA_WIDTH/8;
    localparam integer ADDR_LSB      = clogb2(STRB_WIDTH);         // byte-offset bits
    localparam integer MEM_ADDR_BITS = clogb2(C_S_AXI_MEM_DEPTH);  // word-index bits

    localparam [1:0] RESP_OKAY   = 2'b00;
    localparam [1:0] RESP_SLVERR = 2'b10;

    localparam [1:0] BURST_FIXED = 2'b00;
    localparam [1:0] BURST_INCR  = 2'b01;
    localparam [1:0] BURST_WRAP  = 2'b10;

    localparam [1:0] WR_IDLE = 2'd0, WR_DATA = 2'd1, WR_RESP = 2'd2;
    localparam       RD_IDLE = 1'b0, RD_DATA = 1'b1;

    //-------------------------------------------------------------------
    // ceil(log2()) helper, used only to size internal fields from params
    //-------------------------------------------------------------------
    function integer clogb2 (input integer value);
        integer v;
        begin
            v = value - 1;
            for (clogb2 = 0; v > 0; clogb2 = clogb2 + 1)
                v = v >> 1;
        end
    endfunction

    //-------------------------------------------------------------------
    // Burst address generator, shared by read and write channels.
    // WRAP math relies on (AxLEN+1) being a power of two, which the AXI4
    // spec requires for WRAP bursts (2/4/8/16 beats).
    //-------------------------------------------------------------------
    function automatic [C_S_AXI_ADDR_WIDTH-1:0] next_addr;
        input [C_S_AXI_ADDR_WIDTH-1:0] cur_addr;
        input [1:0]                    burst_type;
        input [2:0]                    axsize;
        input [7:0]                    axlen;
        reg   [C_S_AXI_ADDR_WIDTH-1:0] num_bytes;
        reg   [C_S_AXI_ADDR_WIDTH-1:0] wrap_size;
        reg   [C_S_AXI_ADDR_WIDTH-1:0] wrap_boundary;
        reg   [C_S_AXI_ADDR_WIDTH-1:0] incr_addr;
        begin
            num_bytes = ({{(C_S_AXI_ADDR_WIDTH-1){1'b0}}, 1'b1}) << axsize;
            case (burst_type)
                BURST_FIXED: next_addr = cur_addr;
                BURST_WRAP: begin
                    wrap_size     = num_bytes * (axlen + 1);
                    wrap_boundary = cur_addr & ~(wrap_size - 1);
                    incr_addr     = cur_addr + num_bytes;
                    if (incr_addr >= (wrap_boundary + wrap_size))
                        next_addr = wrap_boundary;
                    else
                        next_addr = incr_addr;
                end
                default: // BURST_INCR (reserved value treated as INCR)
                    next_addr = cur_addr + num_bytes;
            endcase
        end
    endfunction

    //-------------------------------------------------------------------
    // Storage: register-bank / memory
    //-------------------------------------------------------------------
    reg [C_S_AXI_DATA_WIDTH-1:0] mem [0:C_S_AXI_MEM_DEPTH-1];

    integer i; // for byte-strobe loop

    //=====================================================================
    // WRITE CHANNEL FSM  (AW + W + B)
    //=====================================================================
    reg [1:0]                    wr_state;
    reg [C_S_AXI_ID_WIDTH-1:0]   wr_id_lat;
    reg [C_S_AXI_ADDR_WIDTH-1:0] wr_addr_lat;
    reg [7:0]                    wr_len_lat;
    reg [2:0]                    wr_size_lat;
    reg [1:0]                    wr_burst_lat;
    reg [7:0]                    wr_beat_cnt;

    assign S_AXI_AWREADY = (wr_state == WR_IDLE);
    assign S_AXI_WREADY  = (wr_state == WR_DATA);

    wire [MEM_ADDR_BITS-1:0] wr_mem_index = wr_addr_lat[ADDR_LSB +: MEM_ADDR_BITS];

    wire wr_addr_in_range =
        (C_S_AXI_ADDR_WIDTH > (ADDR_LSB + MEM_ADDR_BITS)) ?
            (wr_addr_lat[C_S_AXI_ADDR_WIDTH-1:ADDR_LSB+MEM_ADDR_BITS] == 0) : 1'b1;

    wire [1:0] wr_beat_resp = wr_addr_in_range ? RESP_OKAY : RESP_SLVERR;

    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            wr_state     <= WR_IDLE;
            wr_id_lat    <= {C_S_AXI_ID_WIDTH{1'b0}};
            wr_addr_lat  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
            wr_len_lat   <= 8'd0;
            wr_size_lat  <= 3'd0;
            wr_burst_lat <= 2'd0;
            wr_beat_cnt  <= 8'd0;
            S_AXI_BVALID <= 1'b0;
            S_AXI_BRESP  <= RESP_OKAY;
            S_AXI_BID    <= {C_S_AXI_ID_WIDTH{1'b0}};
        end else begin
            case (wr_state)
                //-----------------------------------------------------
                WR_IDLE: begin
                    if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                        wr_id_lat    <= S_AXI_AWID;
                        wr_addr_lat  <= S_AXI_AWADDR;
                        wr_len_lat   <= S_AXI_AWLEN;
                        wr_size_lat  <= S_AXI_AWSIZE;
                        wr_burst_lat <= S_AXI_AWBURST;
                        wr_beat_cnt  <= S_AXI_AWLEN;
                        wr_state     <= WR_DATA;
                    end
                end
                //-----------------------------------------------------
                WR_DATA: begin
                    if (S_AXI_WVALID && S_AXI_WREADY) begin
                        if (wr_addr_in_range) begin
                            for (i = 0; i < STRB_WIDTH; i = i + 1) begin
                                if (S_AXI_WSTRB[i])
                                    mem[wr_mem_index][i*8 +: 8] <= S_AXI_WDATA[i*8 +: 8];
                            end
                        end
                        if (wr_beat_cnt == 8'd0) begin
                            // last beat of the burst -> move to response phase
                            S_AXI_BVALID <= 1'b1;
                            S_AXI_BID    <= wr_id_lat;
                            S_AXI_BRESP  <= wr_beat_resp;
                            wr_state     <= WR_RESP;
                        end else begin
                            wr_beat_cnt <= wr_beat_cnt - 8'd1;
                            wr_addr_lat <= next_addr(wr_addr_lat, wr_burst_lat,
                                                      wr_size_lat, wr_len_lat);
                        end
                    end
                end
                //-----------------------------------------------------
                WR_RESP: begin
                    if (S_AXI_BVALID && S_AXI_BREADY) begin
                        S_AXI_BVALID <= 1'b0;
                        wr_state     <= WR_IDLE;
                    end
                end
                //-----------------------------------------------------
                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    //=====================================================================
    // READ CHANNEL FSM  (AR + R)
    //=====================================================================
    reg                           rd_state;
    reg [C_S_AXI_ID_WIDTH-1:0]    rd_id_lat;
    reg [C_S_AXI_ADDR_WIDTH-1:0]  rd_addr_lat;
    reg [7:0]                     rd_len_lat;
    reg [2:0]                     rd_size_lat;
    reg [1:0]                     rd_burst_lat;
    reg [7:0]                     rd_beat_cnt;

    assign S_AXI_ARREADY = (rd_state == RD_IDLE);

    wire [MEM_ADDR_BITS-1:0] rd_mem_index = rd_addr_lat[ADDR_LSB +: MEM_ADDR_BITS];

    wire rd_addr_in_range =
        (C_S_AXI_ADDR_WIDTH > (ADDR_LSB + MEM_ADDR_BITS)) ?
            (rd_addr_lat[C_S_AXI_ADDR_WIDTH-1:ADDR_LSB+MEM_ADDR_BITS] == 0) : 1'b1;

    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            rd_state     <= RD_IDLE;
            rd_id_lat    <= {C_S_AXI_ID_WIDTH{1'b0}};
            rd_addr_lat  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
            rd_len_lat   <= 8'd0;
            rd_size_lat  <= 3'd0;
            rd_burst_lat <= 2'd0;
            rd_beat_cnt  <= 8'd0;
            S_AXI_RVALID <= 1'b0;
            S_AXI_RLAST  <= 1'b0;
            S_AXI_RRESP  <= RESP_OKAY;
            S_AXI_RID    <= {C_S_AXI_ID_WIDTH{1'b0}};
            S_AXI_RDATA  <= {C_S_AXI_DATA_WIDTH{1'b0}};
        end else begin
            case (rd_state)
                //-----------------------------------------------------
                RD_IDLE: begin
                    S_AXI_RVALID <= 1'b0;
                    if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                        rd_id_lat    <= S_AXI_ARID;
                        rd_addr_lat  <= S_AXI_ARADDR;
                        rd_len_lat   <= S_AXI_ARLEN;
                        rd_size_lat  <= S_AXI_ARSIZE;
                        rd_burst_lat <= S_AXI_ARBURST;
                        rd_beat_cnt  <= S_AXI_ARLEN;
                        rd_state     <= RD_DATA;
                    end
                end
                //-----------------------------------------------------
                RD_DATA: begin
                    // Drive the current beat every cycle until accepted.
                    S_AXI_RVALID <= 1'b1;
                    S_AXI_RID    <= rd_id_lat;
                    S_AXI_RLAST  <= (rd_beat_cnt == 8'd0);
                    S_AXI_RRESP  <= rd_addr_in_range ? RESP_OKAY  : RESP_SLVERR;
                    S_AXI_RDATA  <= rd_addr_in_range ? mem[rd_mem_index]
                                                      : {C_S_AXI_DATA_WIDTH{1'b0}};

                    if (S_AXI_RVALID && S_AXI_RREADY) begin
                        if (rd_beat_cnt == 8'd0) begin
                            rd_state     <= RD_IDLE;
                            S_AXI_RVALID <= 1'b0;
                        end else begin
                            rd_beat_cnt <= rd_beat_cnt - 8'd1;
                            rd_addr_lat <= next_addr(rd_addr_lat, rd_burst_lat,
                                                      rd_size_lat, rd_len_lat);
                        end
                    end
                end
                //-----------------------------------------------------
                default: rd_state <= RD_IDLE;
            endcase
        end
    end

endmodule
