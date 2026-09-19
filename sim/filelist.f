# filelist.f
# File        : filelist.f
# Description : Complete file list for AXI4 slave UVM testbench compilation.
#               Files are listed in dependency order.
# Author      : Verification Engineer
# Date        : 2026-09-18
# Revision    : 1.0
#
# Usage:
#   QuestaSim:  vlog -f filelist.f
#   VCS:        vcs -f filelist.f
#   Xcelium:    xrun -f filelist.f

# -----------------------------------------------------------------------
# Compilation Options
# -----------------------------------------------------------------------
+incdir+../dv/defines
+incdir+../dv/interface
+incdir+../dv/agent
+incdir+../dv/seq_lib
+incdir+../dv/env
+incdir+../dv/test
+incdir+../dv/pkg

# UVM library (adjust path for your simulator)
-uvmhome $UVM_HOME

# -----------------------------------------------------------------------
# RTL Files (DUT)
# -----------------------------------------------------------------------
../rtl/axi4_slave.v

# -----------------------------------------------------------------------
# Verification: Defines and Typedefs
# -----------------------------------------------------------------------
../dv/defines/axi4_defines.svh
../dv/defines/axi4_typedefs.svh
../dv/defines/axi4_macros.svh

# -----------------------------------------------------------------------
# Verification: Interface and Assertions
# -----------------------------------------------------------------------
../dv/interface/axi4_if.sv
../dv/interface/axi4_assertions.sv
../dv/interface/axi4_whitebox_assertions.sv

# -----------------------------------------------------------------------
# Verification: Agent Components
# -----------------------------------------------------------------------
../dv/agent/axi4_seq_item.sv
../dv/agent/axi4_agent_config.sv
../dv/agent/axi4_driver.sv
../dv/agent/axi4_sequencer.sv
../dv/agent/axi4_monitor.sv
../dv/agent/axi4_coverage.sv
../dv/agent/axi4_agent.sv

# -----------------------------------------------------------------------
# Verification: Sequence Library
# -----------------------------------------------------------------------
../dv/seq_lib/axi4_write_seq.sv
../dv/seq_lib/axi4_read_seq.sv
../dv/seq_lib/axi4_mem_sweep_seq.sv
../dv/seq_lib/axi4_addr_map_seq.sv
../dv/seq_lib/axi4_wlast_mismatch_seq.sv
../dv/seq_lib/axi4_master_not_ready_seq.sv
../dv/seq_lib/axi4_full_mem_write_seq.sv
../dv/seq_lib/axi4_full_mem_read_seq.sv
../dv/seq_lib/axi4_boundary_seq.sv
../dv/seq_lib/axi4_adjacent_oor_seq.sv
../dv/seq_lib/axi4_wstrb_zero_seq.sv
../dv/seq_lib/axi4_byte_lane_seq.sv
../dv/seq_lib/axi4_interleaved_rw_seq.sv
../dv/seq_lib/axi4_reset_during_burst_seq.sv
../dv/seq_lib/axi4_consecutive_oor_seq.sv
../dv/seq_lib/axi4_wrap_len_seq.sv
../dv/seq_lib/axi4_max_incr_seq.sv

# -----------------------------------------------------------------------
# Verification: Environment Components
# -----------------------------------------------------------------------
../dv/env/axi4_env_config.sv
../dv/env/axi4_ref_model.sv
../dv/env/axi4_scoreboard.sv
../dv/env/axi4_virtual_sequencer.sv
../dv/env/axi4_env.sv

# -----------------------------------------------------------------------
# Verification: Tests (Layer 0 - Protocol Compliance)
# -----------------------------------------------------------------------
../dv/test/tc-001.sv
../dv/test/tc-002.sv
../dv/test/tc-003.sv
../dv/test/tc-004.sv
../dv/test/tc-005.sv
../dv/test/tc-006.sv
../dv/test/tc-007.sv
../dv/test/tc-008.sv
../dv/test/tc-009.sv
../dv/test/tc-010.sv
../dv/test/tc-011.sv
../dv/test/tc-012.sv
../dv/test/tc-013.sv
../dv/test/tc-014.sv
../dv/test/tc-015.sv
../dv/test/tc-016.sv
../dv/test/tc-017.sv

# -----------------------------------------------------------------------
# Verification: Tests (Layer 1 - Memory Sweep)
# -----------------------------------------------------------------------
../dv/test/tc-018.sv
../dv/test/tc-019.sv
../dv/test/tc-020.sv
../dv/test/tc-021.sv
../dv/test/tc-022.sv
../dv/test/tc-023.sv
../dv/test/tc-024.sv
../dv/test/tc-025.sv
../dv/test/tc-026.sv
../dv/test/tc-027.sv

# -----------------------------------------------------------------------
# Verification: Tests (Layer 2 - Corner Cases & Stress)
# -----------------------------------------------------------------------
../dv/test/tc-028.sv
../dv/test/tc-029.sv
../dv/test/tc-030.sv
../dv/test/tc-031.sv
../dv/test/tc-032.sv
../dv/test/tc-033.sv
../dv/test/tc-034.sv
../dv/test/tc-035.sv
../dv/test/tc-036.sv
../dv/test/tc-037.sv
../dv/test/tc-038.sv
../dv/test/tc-039.sv
../dv/test/tc-040.sv
../dv/test/tc-041.sv

# -----------------------------------------------------------------------
# Verification: Regression Test
# -----------------------------------------------------------------------
../dv/test/axi4_regression_test.sv

# -----------------------------------------------------------------------
# Verification: Packages
# -----------------------------------------------------------------------
../dv/pkg/axi4_agent_pkg.sv
../dv/seq_lib/axi4_seq_lib_pkg.sv

# -----------------------------------------------------------------------
# Verification: Top-Level Testbench
# -----------------------------------------------------------------------
../dv/top/axi4_tb_top.sv

# -----------------------------------------------------------------------
# Compilation Switches (simulator-specific, uncomment as needed)
# -----------------------------------------------------------------------
# QuestaSim:
# +cover=bcesf
# -timescale=1ns/1ps

# VCS:
# -sverilog
# -ntb_opts uvm-1.2
# -timescale=1ns/1ps
# -full64

# Xcelium:
# -sv
# -uvm
# -timescale 1ns/1ps
# -access +rwc
