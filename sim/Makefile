# Makefile
# File        : Makefile
# Description : Build and simulation automation for AXI4 slave UVM testbench.
#               Supports QuestaSim, VCS, and Xcelium simulators.
# Author      : Verification Engineer
# Date        : 2026-09-18
# Revision    : 1.0
#
# Usage:
#   make compile        - Compile testbench
#   make sim TEST=tc_001 - Run specific test
#   make regression     - Run all tests
#   make cov            - Generate coverage report
#   make clean          - Clean build artifacts

# -----------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------
SHELL := /bin/bash

# Simulator selection (questa, vcs, xcelium)
SIM ?= questa

# Directories
TB_ROOT := $(shell pwd)/..
RTL_DIR := $(TB_ROOT)/rtl
DV_DIR  := $(TB_ROOT)/dv
SIM_DIR := $(TB_ROOT)/sim
COV_DIR := $(SIM_DIR)/coverage
LOG_DIR := $(SIM_DIR)/logs
WORK_DIR := $(SIM_DIR)/work

# File lists
FILELIST := $(SIM_DIR)/filelist.f

# Default test
TEST ?= tc_001

# UVM verbosity
VERBOSITY ?= UVM_MEDIUM

# Simulation options
WAVES ?= 0
GUI ?= 0
SEED ?= random
TIMEOUT ?= 100000

# Coverage options
COV_MERGE_DIR := $(COV_DIR)/merged
UCDB_FILES := $(wildcard $(COV_DIR)/*.ucdb)

# -----------------------------------------------------------------------
# QuestaSim Configuration
# -----------------------------------------------------------------------
ifeq ($(SIM),questa)
    VLIB := vlib
    VLOG := vlog
    VSIM := vsim

    VLOG_OPTS := -sv \
                 -timescale=1ns/1ps \
                 +incdir+$(DV_DIR)/defines \
                 +incdir+$(DV_DIR)/interface \
                 +incdir+$(DV_DIR)/agent \
                 +incdir+$(DV_DIR)/seq_lib \
                 +incdir+$(DV_DIR)/env \
                 +incdir+$(DV_DIR)/test \
                 -L $(UVM_HOME) \
                 -work $(WORK_DIR)

    VSIM_OPTS := -sv_seed=$(SEED) \
                 +UVM_TESTNAME=$(TEST) \
                 +UVM_VERBOSITY=$(VERBOSITY) \
                 -L $(UVM_HOME) \
                 -work $(WORK_DIR)

    ifeq ($(WAVES),1)
        VSIM_OPTS += +DUMP_WAVES -do "log -r /*; run -all"
    else
        VSIM_OPTS += -c -do "run -all; quit -f"
    endif

    ifeq ($(GUI),1)
        VSIM_OPTS += -gui
    else
        VSIM_OPTS += -c
    endif

    COV_OPTS := +cover=bcesf \
                -coverstore $(COV_DIR)

    COV_MERGE := vcover merge
    COV_REPORT := vcover report
endif

# -----------------------------------------------------------------------
# VCS Configuration
# -----------------------------------------------------------------------
ifeq ($(SIM),vcs)
    VCS := vcs

    VCS_OPTS := -sverilog \
                -full64 \
                -ntb_opts uvm-1.2 \
                -timescale=1ns/1ps \
                +incdir+$(DV_DIR)/defines \
                +incdir+$(DV_DIR)/interface \
                +incdir+$(DV_DIR)/agent \
                +incdir+$(DV_DIR)/seq_lib \
                +incdir+$(DV_DIR)/env \
                +incdir+$(DV_DIR)/test \
                -o $(SIM_DIR)/simv

    SIMV_OPTS := +UVM_TESTNAME=$(TEST) \
                 +UVM_VERBOSITY=$(VERBOSITY) \
                 +ntb_random_seed=$(SEED)

    ifeq ($(WAVES),1)
        SIMV_OPTS += +DUMP_WAVES
    endif

    COV_OPTS := -cm line+cond+fsm+tgl+branch+assert

    COV_REPORT := urg -dir $(COV_DIR)
endif

# -----------------------------------------------------------------------
# Xcelium Configuration
# -----------------------------------------------------------------------
ifeq ($(SIM),xcelium)
    XRUN := xrun

    XRUN_OPTS := -sv \
                 -uvm \
                 -timescale 1ns/1ps \
                 -access +rwc \
                 +incdir+$(DV_DIR)/defines \
                 +incdir+$(DV_DIR)/interface \
                 +incdir+$(DV_DIR)/agent \
                 +incdir+$(DV_DIR)/seq_lib \
                 +incdir+$(DV_DIR)/env \
                 +incdir+$(DV_DIR)/test \
                 -uvmhome $(UVM_HOME)

    RUN_OPTS := +UVM_TESTNAME=$(TEST) \
                +UVM_VERBOSITY=$(VERBOSITY) \
                -svseed $(SEED)

    ifeq ($(WAVES),1)
        RUN_OPTS += +DUMP_WAVES
    endif

    COV_OPTS := -coverage all

    COV_REPORT := imc -exec cov_report.tcl
endif

# -----------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------
.PHONY: all compile sim regression clean help cov

all: compile

help:
	@echo "========================================="
	@echo "  AXI4 Slave UVM Testbench Makefile"
	@echo "========================================="
	@echo ""
	@echo "Targets:"
	@echo "  compile          - Compile testbench"
	@echo "  sim              - Run single test (TEST=tc_001)"
	@echo "  regression       - Run all tests"
	@echo "  cov              - Generate coverage report"
	@echo "  clean            - Clean build artifacts"
	@echo ""
	@echo "Options:"
	@echo "  SIM=<simulator>  - Select simulator (questa/vcs/xcelium)"
	@echo "  TEST=<testname>  - Test to run (default: tc_001)"
	@echo "  VERBOSITY=<lvl>  - UVM verbosity (default: UVM_MEDIUM)"
	@echo "  WAVES=1          - Enable waveform dump"
	@echo "  GUI=1            - Launch GUI (QuestaSim only)"
	@echo "  SEED=<value>     - Random seed (default: random)"
	@echo ""
	@echo "Examples:"
	@echo "  make compile"
	@echo "  make sim TEST=tc_028 WAVES=1"
	@echo "  make regression"
	@echo "  make cov"
	@echo ""

# -----------------------------------------------------------------------
# Directory Setup
# -----------------------------------------------------------------------
$(WORK_DIR) $(COV_DIR) $(LOG_DIR):
	@mkdir -p $@

# -----------------------------------------------------------------------
# Compilation
# -----------------------------------------------------------------------
compile: $(WORK_DIR)
	@echo "========================================="
	@echo "  Compiling AXI4 Slave Testbench"
	@echo "  Simulator: $(SIM)"
	@echo "========================================="
ifeq ($(SIM),questa)
	@$(VLIB) $(WORK_DIR)
	@$(VLOG) $(VLOG_OPTS) $(COV_OPTS) -f $(FILELIST)
else ifeq ($(SIM),vcs)
	@$(VCS) $(VCS_OPTS) $(COV_OPTS) -f $(FILELIST)
else ifeq ($(SIM),xcelium)
	@$(XRUN) $(XRUN_OPTS) $(COV_OPTS) -elaborate -f $(FILELIST)
else
	@echo "ERROR: Unknown simulator: $(SIM)"
	@exit 1
endif
	@echo "Compilation complete."

# -----------------------------------------------------------------------
# Single Test Simulation
# -----------------------------------------------------------------------
sim: compile $(LOG_DIR) $(COV_DIR)
	@echo "========================================="
	@echo "  Running Test: $(TEST)"
	@echo "  Verbosity: $(VERBOSITY)"
	@echo "  Seed: $(SEED)"
	@echo "========================================="
ifeq ($(SIM),questa)
	@$(VSIM) $(VSIM_OPTS) $(COV_OPTS) \
		axi4_tb_top \
		-l $(LOG_DIR)/$(TEST).log
else ifeq ($(SIM),vcs)
	@$(SIM_DIR)/simv $(SIMV_OPTS) $(COV_OPTS) \
		-l $(LOG_DIR)/$(TEST).log
else ifeq ($(SIM),xcelium)
	@$(XRUN) $(XRUN_OPTS) $(RUN_OPTS) $(COV_OPTS) \
		-f $(FILELIST) \
		-l $(LOG_DIR)/$(TEST).log
endif
	@echo "Test $(TEST) complete. Log: $(LOG_DIR)/$(TEST).log"

# -----------------------------------------------------------------------
# Regression - Run all tests
# -----------------------------------------------------------------------
LAYER0_TESTS := tc_001 tc_002 tc_003 tc_004 tc_005 tc_006 tc_007 tc_008 \
                tc_009 tc_010 tc_011 tc_012 tc_013 tc_014 tc_015 tc_016 tc_017

LAYER1_TESTS := tc_018 tc_019 tc_020 tc_021 tc_022 tc_023 tc_024 tc_025 \
                tc_026 tc_027

LAYER2_TESTS := tc_028 tc_029 tc_030 tc_031 tc_032 tc_033 tc_034 tc_035 \
                tc_036 tc_037 tc_038 tc_039 tc_040 tc_041

ALL_TESTS := $(LAYER0_TESTS) $(LAYER1_TESTS) $(LAYER2_TESTS)

regression: compile $(LOG_DIR) $(COV_DIR)
	@echo "========================================="
	@echo "  Running Regression Suite"
	@echo "  Total Tests: $(words $(ALL_TESTS))"
	@echo "========================================="
	@for test in $(ALL_TESTS); do \
		echo "Running $$test..."; \
		$(MAKE) sim TEST=$$test WAVES=0 GUI=0 || exit 1; \
	done
	@echo ""
	@echo "========================================="
	@echo "  Regression Complete!"
	@echo "========================================="
	@$(MAKE) summary

# Run comprehensive regression test
regression_comprehensive: compile $(LOG_DIR) $(COV_DIR)
	@echo "========================================="
	@echo "  Running Comprehensive Regression Test"
	@echo "========================================="
	@$(MAKE) sim TEST=axi4_regression_test WAVES=0

# -----------------------------------------------------------------------
# Test Summary
# -----------------------------------------------------------------------
summary:
	@echo ""
	@echo "========================================="
	@echo "  Test Summary"
	@echo "========================================="
	@echo "Passed tests:"
	@grep -l "UVM_INFO.*Test.*PASSED" $(LOG_DIR)/*.log 2>/dev/null || echo "  (checking logs...)"
	@echo ""
	@echo "Failed tests:"
	@grep -l "UVM_ERROR\|UVM_FATAL" $(LOG_DIR)/*.log 2>/dev/null || echo "  None"
	@echo ""

# -----------------------------------------------------------------------
# Coverage Reporting
# -----------------------------------------------------------------------
cov: $(COV_DIR)
	@echo "========================================="
	@echo "  Generating Coverage Report"
	@echo "========================================="
ifeq ($(SIM),questa)
	@mkdir -p $(COV_MERGE_DIR)
	@$(COV_MERGE) $(COV_MERGE_DIR)/merged.ucdb $(UCDB_FILES)
	@$(COV_REPORT) -html -htmldir $(COV_DIR)/html $(COV_MERGE_DIR)/merged.ucdb
	@echo "Coverage report: $(COV_DIR)/html/index.html"
else ifeq ($(SIM),vcs)
	@$(COV_REPORT) -dir $(COV_DIR)/*.vdb
	@echo "Coverage report: $(COV_DIR)/urgReport/index.html"
else ifeq ($(SIM),xcelium)
	@echo "Coverage report generation for Xcelium - see imc GUI"
endif

# -----------------------------------------------------------------------
# Clean
# -----------------------------------------------------------------------
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(WORK_DIR)
	@rm -rf $(COV_DIR)
	@rm -rf $(LOG_DIR)
	@rm -rf $(SIM_DIR)/*.log
	@rm -rf $(SIM_DIR)/*.vcd
	@rm -rf $(SIM_DIR)/*.wlf
	@rm -rf $(SIM_DIR)/simv*
	@rm -rf $(SIM_DIR)/csrc
	@rm -rf $(SIM_DIR)/.simvision
	@rm -rf $(SIM_DIR)/xcelium.d
	@rm -rf $(SIM_DIR)/INCA_libs
	@rm -rf transcript
	@echo "Clean complete."

# -----------------------------------------------------------------------
# Phony targets
# -----------------------------------------------------------------------
.PHONY: summary regression_comprehensive
