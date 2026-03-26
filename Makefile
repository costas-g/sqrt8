# 1. Variables
GHDL = ghdl
# VHDL_STD = --std=08
VHDL_STD = 
# FLAGS = --ieee=synopsys
FLAGS = 

# 2. Wildcard Paths
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
HDL_FILES = $(wildcard src/*.vhd)
TB_FILES  = $(wildcard src/tb_*.vhd)
ALL_FILES = $(HDL_FILES) $(TB_FILES)
BUILD_DIR = build

# 3. Project Configuration
BASE_NAME = sqrt8
PROJ_NAME = $(BASE_NAME)_project
TOP_TB = tb_$(BASE_NAME)
SETUP_TCL = $(ROOT_DIR)/setup_vivado_project.tcl
# PROJ_XPR  = $(BUILD_DIR)/$(PROJ_NAME)/$(PROJ_NAME).xpr
PROJ_XPR  = $(PROJ_NAME)/$(PROJ_NAME).xpr

VCD_FILE = out/output.vcd

# --- Targets ---

# Default: Analyze, Elaborate, and Run
all: run

# Step 1: Analyze everything found in the subfolders
# analyze:
# 	$(GHDL) -a $(VHDL_STD) $(FLAGS) $(ALL_FILES)
analyze:
	$(GHDL) -i $(VHDL_STD) $(FLAGS) $(ALL_FILES)
	$(GHDL) -m $(VHDL_STD) $(FLAGS) tb_sqrt8

# Step 2: Elaborate the Top Testbench
elaborate: analyze
	$(GHDL) -e $(VHDL_STD) $(FLAGS) $(TOP_TB)

# Step 3: Run the simulation
run: elaborate
	$(GHDL) -r $(VHDL_STD) $(FLAGS) $(TOP_TB) --vcd=$(VCD_FILE) --stop-time=3000ns

# Step 4: Open GTKWave
view: 
	gtkwave $(VCD_FILE)

# Rule to create the directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
synth: | $(BUILD_DIR)
	cd $(BUILD_DIR) && vivado -mode batch -source $(SETUP_TCL)

# Target to open the project in the Vivado GUI
gui:
	cd $(BUILD_DIR) && vivado $(PROJ_XPR)

# Target to export the current project settings to a Tcl script
save:
	@echo "write_project_tcl -force rebuild_project.tcl" > build/save_cmd.tcl
	@echo "exit" >> build/save_cmd.tcl
	cd build && vivado -mode batch $(PROJ_NAME)/$(PROJ_NAME).xpr -notrace -source save_cmd.tcl
	@rm build/save_cmd.tcl

rebuild:
	cd $(BUILD_DIR) && vivado -mode batch -source rebuild_project.tcl

# Cleanup
# clean:
# 	$(GHDL) --remove
# 	rm -rf *.o *.cf $(TOP_TB) $(VCD_FILE)
clean:
	$(GHDL) --remove
	rm -rf *.o *.cf