# AXI4 Slave UVM Testbench

A comprehensive UVM 1.2 testbench for verifying an AXI4 slave memory controller with 1024-word depth.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Directory Structure](#directory-structure)
4. [Quick Start](#quick-start)
5. [Running Tests](#running-tests)
6. [Coverage Analysis](#coverage-analysis)
7. [Test List](#test-list)
8. [Configuration](#configuration)
9. [Debugging](#debugging)
10. [Extending the Testbench](#extending-the-testbench)

---

## Overview

This testbench provides complete verification coverage for an AXI4 slave DUT with:
- **231 testcases** covering protocol compliance, memory sweep, and stress scenarios
- **32 SystemVerilog assertions** for protocol checking
- **15 functional covergroups** for feature coverage
- Full AXI4 protocol support (FIXED, INCR, WRAP bursts)
- Layered UVM architecture with sequences, agents, and scoreboards

**DUT Specifications:**
- Protocol: AXI4 (ARM AMBA 4)
- Data Width: 32 bits
- Address Width: 32 bits
- ID Width: 4 bits
- Memory Depth: 1024 words (4 KB)
- Valid Address Range: 0x0000 - 0x0FFF

---

## Features

### Verification Components
- ✅ **UVM Agent**: Driver, monitor, sequencer, coverage
- ✅ **Reference Model**: Golden memory model with exact DUT behavior
- ✅ **Scoreboard**: Automatic transaction checking
- ✅ **Assertions**: 32 SVA properties (19 black-box, 13 white-box)
- ✅ **Coverage**: 15 covergroups with cross-coverage

### Test Layers
- **Layer 0** (17 tests): Protocol compliance (single, burst, error handling)
- **Layer 1** (200 tests): Complete memory sweep (all 1024 words)
- **Layer 2** (14 tests): Corner cases and stress (max bursts, reset, boundaries)

### Supported Simulators
- Mentor QuestaSim (recommended)
- Synopsys VCS
- Cadence Xcelium

---

## Directory Structure

```
axi4_slave_uvm/
├── rtl/
│   └── axi4_slave.v              # DUT (provide your own)
├── dv/
│   ├── defines/
│   │   ├── axi4_defines.svh      # Constants and parameters
│   │   ├── axi4_typedefs.svh     # Type definitions
│   │   └── axi4_macros.svh       # Utility macros
│   ├── interface/
│   │   ├── axi4_if.sv            # AXI4 interface with clocking blocks
│   │   ├── axi4_assertions.sv    # Black-box assertions (19)
│   │   └── axi4_whitebox_assertions.sv # White-box assertions (13)
│   ├── agent/
│   │   ├── axi4_seq_item.sv      # Transaction item
│   │   ├── axi4_driver.sv        # Bus driver
│   │   ├── axi4_monitor.sv       # Bus monitor
│   │   ├── axi4_sequencer.sv     # UVM sequencer
│   │   ├── axi4_coverage.sv      # Functional coverage (12 covergroups)
│   │   ├── axi4_agent_config.sv  # Agent configuration
│   │   └── axi4_agent.sv         # Agent wrapper
│   ├── seq_lib/
│   │   ├── axi4_write_seq.sv     # Basic write sequence
│   │   ├── axi4_read_seq.sv      # Basic read sequence
│   │   ├── axi4_mem_sweep_seq.sv # Memory sweep
│   │   ├── axi4_full_mem_write_seq.sv  # Full memory write
│   │   ├── axi4_full_mem_read_seq.sv   # Full memory read
│   │   ├── axi4_boundary_seq.sv  # Boundary testing
│   │   ├── axi4_wstrb_zero_seq.sv      # WSTRB testing
│   │   ├── axi4_byte_lane_seq.sv       # Byte lane testing
│   │   ├── axi4_wrap_len_seq.sv        # WRAP bursts
│   │   ├── axi4_max_incr_seq.sv        # Max burst length
│   │   └── ... (17 sequences total)
│   ├── env/
│   │   ├── axi4_ref_model.sv     # Golden reference model
│   │   ├── axi4_scoreboard.sv    # Transaction checker (3 covergroups)
│   │   ├── axi4_env_config.sv    # Environment configuration
│   │   ├── axi4_virtual_sequencer.sv   # Virtual sequencer
│   │   └── axi4_env.sv           # Environment wrapper
│   ├── test/
│   │   ├── tc-001.sv ... tc-041.sv     # Individual tests (41 files)
│   │   └── axi4_regression_test.sv     # Comprehensive regression
│   ├── pkg/
│   │   └── axi4_agent_pkg.sv     # Agent package
│   └── top/
│       └── axi4_tb_top.sv        # Top-level testbench
├── sim/
│   ├── Makefile                  # Build automation
│   ├── filelist.f                # Compilation file list
│   ├── logs/                     # Simulation logs (created)
│   ├── coverage/                 # Coverage databases (created)
│   └── work/                     # Compiled library (created)
└── docs/
    ├── verification_plan.md      # Traceability matrix
    ├── batch9_summary.md         # Layer 2 delivery summary
    └── README.md                 # This file
```

---

## Quick Start

### Prerequisites

1. **Simulator**: QuestaSim, VCS, or Xcelium installed
2. **UVM Library**: Set `$UVM_HOME` environment variable
3. **DUT**: Place your `axi4_slave.v` in `rtl/` directory

### Build and Run First Test

```bash
cd sim

# Compile testbench
make compile SIM=questa

# Run a single test
make sim TEST=tc_001

# Run with waveform dump
make sim TEST=tc_001 WAVES=1

# Run with GUI
make sim TEST=tc_001 GUI=1 WAVES=1
```

---

## Running Tests

### Single Test Execution

```bash
# Basic run
make sim TEST=tc_028

# With custom seed
make sim TEST=tc_028 SEED=12345

# With high verbosity
make sim TEST=tc_028 VERBOSITY=UVM_HIGH

# All options combined
make sim TEST=tc_028 WAVES=1 GUI=1 SEED=42 VERBOSITY=UVM_DEBUG
```

### Regression Testing

```bash
# Run all 41 individual tests sequentially
make regression

# Run comprehensive regression test (single test, all sequences)
make regression_comprehensive

# Run specific layer
make sim TEST=tc_001  # Layer 0
make sim TEST=tc_028  # Layer 2
```

### Test Selection Examples

**Protocol Tests (Layer 0):**
```bash
make sim TEST=tc_001  # Reset verification
make sim TEST=tc_004  # Write burst INCR
make sim TEST=tc_007  # WRAP burst
make sim TEST=tc_017  # WLAST mismatch
```

**Memory Sweep (Layer 1):**
```bash
make sim TEST=tc_018  # Small memory blocks
make sim TEST=tc_020  # Address map incremental
```

**Stress Tests (Layer 2):**
```bash
make sim TEST=tc_028  # Full memory write (1024 words)
make sim TEST=tc_033  # WSTRB all-zero
make sim TEST=tc_041  # Max INCR burst (256 beats)
```

---

## Coverage Analysis

### Collecting Coverage

Coverage is automatically collected when running tests. To merge and view:

```bash
# Run regression with coverage
make regression

# Generate HTML coverage report
make cov

# View report (QuestaSim)
firefox coverage/html/index.html
```

### Coverage Metrics

The testbench tracks:
- **Code Coverage**: Line, branch, condition, FSM, toggle
- **Functional Coverage**: 15 covergroups with 100+ bins
- **Assertion Coverage**: 32 assertions with pass/fail tracking

**Expected Coverage:**
- Line: >95%
- Branch: >90%
- Functional: 100% (all bins hit by regression)

---

## Test List

### Layer 0: Protocol Compliance (17 tests)

| Test | Description | Key Feature |
|------|-------------|-------------|
| tc_001 | Reset Verification | Async reset behavior |
| tc_002 | Single Read | Basic read transaction |
| tc_003 | Single Write | Basic write transaction |
| tc_004 | Write Burst INCR | Multi-beat write |
| tc_005 | Read Burst INCR | Multi-beat read |
| tc_006 | FIXED Burst | Fixed address burst |
| tc_007 | WRAP Burst | Wrapping address burst |
| tc_008 | Byte Strobe Write | Partial word updates |
| tc_009 | Out-of-Range Write | SLVERR on invalid address |
| tc_010 | Out-of-Range Read | SLVERR + zero data |
| tc_011 | Concurrent R/W | Independent channels |
| tc_012 | Back-to-Back | Zero-gap transactions |
| tc_013 | Narrow Transfer | Sub-word size |
| tc_014 | Master Not Ready (B) | BREADY withholding |
| tc_015 | Master Not Ready (R) | RREADY withholding |
| tc_016 | Reserved BURST | 2'b11 treated as INCR |
| tc_017 | WLAST Mismatch | Protocol violation detect |

### Layer 1: Memory Sweep (200 tests)

Programmatic coverage of all 1024 memory words:
- **tc_018-tc_027**: Various memory access patterns
- **TC-M001 to TC-M200**: 200 address blocks (implemented in sweep sequences)

### Layer 2: Stress & Corner Cases (14 tests)

| Test | Description | Stress Factor |
|------|-------------|---------------|
| tc_028 | Full Memory Write | 128 bursts × 8 words |
| tc_029 | Full Memory Read | 128 bursts × 8 words |
| tc_030 | Boundary Word 0 | Address 0x0000 |
| tc_031 | Boundary Word 1023 | Address 0x0FFC |
| tc_032 | Adjacent OOR | Edge case addresses |
| tc_033 | WSTRB All-Zero | No-op write |
| tc_034 | Byte Lanes | Individual lane access |
| tc_035 | Interleaved R/W | Concurrent stress |
| tc_036 | Reset During Write | Mid-burst reset |
| tc_037 | Reset During Read | Mid-burst reset |
| tc_038 | Consecutive OOR | 10 sequential errors |
| tc_039 | WRAP Length 2 | Minimum WRAP |
| tc_040 | WRAP Length 16 | Large WRAP |
| tc_041 | Max INCR | 256-beat burst |

---

## Configuration

### Changing DUT Parameters

Edit `dv/defines/axi4_defines.svh`:

```systemverilog
`define C_S_AXI_DATA_WIDTH    64   // Change to 64-bit
`define C_S_AXI_MEM_DEPTH     2048 // Double memory size
```

Then recompile:
```bash
make clean
make compile
```

### Adjusting Timeouts

Edit `dv/top/axi4_tb_top.sv`:

```systemverilog
parameter int SIM_TIMEOUT_NS = 200_000_000; // Increase to 200ms
```

### Selecting Simulator

```bash
# Use VCS instead of QuestaSim
make compile SIM=vcs
make sim TEST=tc_001 SIM=vcs

# Use Xcelium
make compile SIM=xcelium
make sim TEST=tc_001 SIM=xcelium
```

---

## Debugging

### Viewing Waveforms

```bash
# Generate VCD waveform
make sim TEST=tc_028 WAVES=1

# View in GTKWave
gtkwave axi4_slave_tb.vcd

# Launch QuestaSim GUI with waves
make sim TEST=tc_028 GUI=1 WAVES=1
```

### Log Files

All simulation logs are saved to `sim/logs/`:

```bash
# View specific test log
cat sim/logs/tc_028.log

# Search for errors
grep UVM_ERROR sim/logs/*.log

# Count passing tests
grep -l "Test.*PASSED" sim/logs/*.log | wc -l
```

### Increasing Verbosity

```bash
# Debug level verbosity
make sim TEST=tc_028 VERBOSITY=UVM_DEBUG

# Full transaction detail
make sim TEST=tc_028 VERBOSITY=UVM_FULL
```

### Common Issues

**Issue: Compilation fails with "UVM_HOME not set"**
```bash
# Solution: Set UVM_HOME
export UVM_HOME=/path/to/uvm-1.2
```

**Issue: Test hangs or times out**
```bash
# Solution: Check objections are dropped
# Review test's run_phase for proper objection handling
```

**Issue: Assertion failures**
```bash
# Solution: Check logs for assertion name
grep "Assertion.*FAILED" sim/logs/tc_028.log
# Review assertion in axi4_assertions.sv
```

---

## Extending the Testbench

### Adding a New Test

1. **Create test file** `dv/test/tc-042.sv`:

```systemverilog
`ifndef TC-042_SV
`define TC-042_SV

`include "axi4_defines.svh"
`include "my_new_seq.sv"

class tc_042 extends uvm_test;
  `uvm_component_utils(tc_042)
  
  axi4_env env;
  axi4_sequencer seqr;
  
  function new(string name = "tc_042", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_env::type_id::create("env", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(axi4_sequencer)::get(this, "", "seqr", seqr))
      `uvm_fatal("NOSEQR", "Sequencer not found")
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    my_new_seq seq = my_new_seq::type_id::create("seq");
    seq.start(seqr);
    
    phase.drop_objection(this);
  endtask
endclass

`endif
```

2. **Add to filelist** `sim/filelist.f`:
```
../dv/test/tc-042.sv
```

3. **Add to Makefile** regression list:
```make
ALL_TESTS := ... tc_042
```

4. **Run the test**:
```bash
make sim TEST=tc_042
```

### Adding a New Sequence

1. **Create sequence** `dv/seq_lib/my_new_seq.sv`:

```systemverilog
class my_new_seq extends uvm_sequence #(axi4_seq_item);
  `uvm_object_utils(my_new_seq)
  
  function new(string name = "my_new_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    axi4_seq_item tx;
    
    tx = axi4_seq_item::type_id::create("tx");
    assert(tx.randomize() with {
      // Your constraints here
    });
    
    start_item(tx);
    finish_item(tx);
  endtask
endclass
```

2. **Add to sequence package** `dv/seq_lib/axi4_seq_lib_pkg.sv`:
```systemverilog
`include "my_new_seq.sv"
```

---

## Testbench Architecture

### UVM Hierarchy

```
axi4_tb_top (module)
  └── run_test()
       └── tc_XXX (test)
            └── axi4_env
                 ├── axi4_agent
                 │    ├── axi4_driver
                 │    ├── axi4_monitor
                 │    ├── axi4_sequencer
                 │    └── axi4_coverage
                 ├── axi4_ref_model
                 ├── axi4_scoreboard
                 └── axi4_virtual_sequencer
```

### Data Flow

```
Sequence → Sequencer → Driver → DUT
                                  ↓
Monitor ← Scoreboard ← Ref Model
   ↓
Coverage
```

---

## Performance

**Typical Simulation Times (QuestaSim on modern CPU):**
- Single test (tc_001): ~0.5 seconds
- Memory sweep (tc_028): ~5 seconds
- Full regression (41 tests): ~3-5 minutes
- Comprehensive regression: ~30 seconds

---

## Support & Contact

**Issues:** Create an issue in the repository  
**Questions:** Contact verification team  
**Documentation:** See `docs/verification_plan.md` for complete traceability

---

## License

[Your License Here]

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-18 | Initial release with 231 tests, 32 assertions, 15 covergroups |

---

**End of README**
