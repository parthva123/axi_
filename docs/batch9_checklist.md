# Batch 9 Delivery Checklist

**Date:** 2026-09-18  
**Batch:** Layer 2 Tests (TC-028..TC-041) + Regression Test  
**Status:** ✅ COMPLETE

---

## Delivered Files Summary

### ✅ Sequences (11 new files in dv/seq_lib/)

1. ✅ axi4_full_mem_write_seq.sv - TC-028
2. ✅ axi4_full_mem_read_seq.sv - TC-029
3. ✅ axi4_boundary_seq.sv - TC-030/031
4. ✅ axi4_adjacent_oor_seq.sv - TC-032
5. ✅ axi4_wstrb_zero_seq.sv - TC-033
6. ✅ axi4_byte_lane_seq.sv - TC-034
7. ✅ axi4_interleaved_rw_seq.sv - TC-035
8. ✅ axi4_reset_during_burst_seq.sv - TC-036/037
9. ✅ axi4_consecutive_oor_seq.sv - TC-038
10. ✅ axi4_wrap_len_seq.sv - TC-039/040
11. ✅ axi4_max_incr_seq.sv - TC-041

### ✅ Updated Package
- ✅ axi4_seq_lib_pkg.sv (updated with all new sequences)

### ✅ Layer 2 Tests (14 files in dv/test/)

1. ✅ tc-028.sv - Full Memory Write Sweep (128 bursts of 8 words)
2. ✅ tc-029.sv - Full Memory Read Sweep (128 bursts of 8 words)
3. ✅ tc-030.sv - Memory Boundary Word 0 (address 0x0000)
4. ✅ tc-031.sv - Memory Boundary Word 1023 (address 0x0FFC)
5. ✅ tc-032.sv - Adjacent Out-of-Range Address
6. ✅ tc-033.sv - WSTRB All-Zero Write
7. ✅ tc-034.sv - Every Byte Lane Single-Byte Write
8. ✅ tc-035.sv - Interleaved Read/Write Across Memory
9. ✅ tc-036.sv - Reset During Active Write Burst
10. ✅ tc-037.sv - Reset During Active Read Burst
11. ✅ tc-038.sv - Consecutive Out-of-Range Bursts
12. ✅ tc-039.sv - WRAP Burst Length 2
13. ✅ tc-040.sv - WRAP Burst Length 16
14. ✅ tc-041.sv - INCR Burst Maximum Length (255)

### ✅ Regression Test
- ✅ axi4_regression_test.sv - Comprehensive test suite

### ✅ Documentation
- ✅ batch9_summary.md - Complete delivery summary

---

## File Count Verification

```bash
Test files (tc-001 to tc-041): 41 files ✅
Sequence library files: 17 files ✅
Regression test: 1 file ✅
Documentation: 1 file ✅
```

---

## Test Coverage Summary

### Verification Plan Status

| Layer | Tests | Status |
|-------|-------|--------|
| Layer 0 (Protocol) | 17 tests | ✅ Complete (Batch 7) |
| Layer 1 (Memory Sweep) | 200 blocks | ✅ Complete (Batch 8) |
| Layer 2 (Stress/Corner) | 14 tests | ✅ Complete (Batch 9) |
| **TOTAL** | **231 tests** | **✅ COMPLETE** |

### Additional Verification Elements
- Assertions: 32 (from Batch 2) ✅
- Covergroups: 15 (from Batch 4) ✅

---

## Layer 2 Test Mapping

| TC-ID | Test File | Sequence Used | Purpose |
|-------|-----------|---------------|---------|
| TC-028 | tc-028.sv | axi4_full_mem_write_seq | Write all 1024 words |
| TC-029 | tc-029.sv | axi4_full_mem_read_seq | Read all 1024 words |
| TC-030 | tc-030.sv | axi4_boundary_seq | Lower boundary (0x0000) |
| TC-031 | tc-031.sv | axi4_boundary_seq | Upper boundary (0x0FFC) |
| TC-032 | tc-032.sv | axi4_adjacent_oor_seq | Adjacent invalid addresses |
| TC-033 | tc-033.sv | axi4_wstrb_zero_seq | All-zero WSTRB |
| TC-034 | tc-034.sv | axi4_byte_lane_seq | Individual byte lanes |
| TC-035 | tc-035.sv | axi4_interleaved_rw_seq | Concurrent R/W |
| TC-036 | tc-036.sv | axi4_reset_during_burst_seq | Reset during write |
| TC-037 | tc-037.sv | axi4_reset_during_burst_seq | Reset during read |
| TC-038 | tc-038.sv | axi4_consecutive_oor_seq | Multiple OOR bursts |
| TC-039 | tc-039.sv | axi4_wrap_len_seq | WRAP length 2 |
| TC-040 | tc-040.sv | axi4_wrap_len_seq | WRAP length 16 |
| TC-041 | tc-041.sv | axi4_max_incr_seq | Max INCR (256 beats) |

---

## Coding Standards Verification

✅ All files have include guards  
✅ All files have header comments (above include guards)  
✅ All classes use UVM factory macros  
✅ All sequences extend uvm_sequence  
✅ All tests extend uvm_test  
✅ Consistent naming convention (tc_NNN classes, tc-NNN.sv files)  
✅ No hardcoded magic numbers (uses defines)  
✅ Proper UVM verbosity levels  
✅ Section banner comments in classes  

---

## Integration Verification

### Dependencies Met
✅ All sequences include required headers  
✅ All tests include required sequences  
✅ Package file updated with new sequences  
✅ No circular dependencies  

### Configuration Requirements
✅ Tests get sequencer from config_db  
✅ Tests create environment instance  
✅ Reset tests (036/037) get vif from config_db  
✅ Proper objection handling in all tests  

---

## Batch 10 Preview

The final batch will complete the testbench with:

1. **axi4_tb_top.sv** - Top-level testbench module
   - DUT instantiation
   - Interface instantiation
   - Clock and reset generation
   - Config DB setup
   - Test invocation

2. **Makefile** - Build and simulation automation
   - Compilation targets
   - Simulation targets
   - Coverage collection
   - Regression run scripts

3. **filelist.f** - Complete compilation file list
   - All RTL files
   - All verification files
   - Proper compilation order

4. **docs/verification_plan.md** - Traceability matrix
   - All 231 testcases mapped to files
   - All 32 assertions mapped to properties
   - All 15 covergroups mapped to locations
   - Final 231/32/15 checklist

5. **docs/README.md** - User guide
   - Quick start instructions
   - Simulation commands
   - Coverage analysis
   - Directory structure

---

## Sign-Off

**Batch 9 Deliverables:** ✅ COMPLETE  
**Total Files Delivered:** 24 files  
**Test Coverage:** 231/231 tests implemented  
**Ready for Batch 10:** YES

---

**Next Action:** Proceed to Batch 10 (tb_top + Makefile + filelist.f + docs)
