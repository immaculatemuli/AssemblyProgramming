# ============================================================
# Makefile — BIT 4220 Task 2: ALU Simulator
# Usage:
#   make          → builds alu_simulator
#   make run      → builds and runs
#   make clean    → removes compiled files
# ============================================================

NASM      = nasm
LD        = ld
NASMFLAGS = -f elf64

all: alu_simulator

alu_simulator: asm/alu_simulator.asm
	@echo "[NASM] Assembling alu_simulator.asm..."
	$(NASM) $(NASMFLAGS) asm/alu_simulator.asm -o alu_simulator.o
	@echo "[LD]   Linking alu_simulator.o..."
	$(LD) alu_simulator.o -o alu_simulator
	@echo "[DONE] alu_simulator is ready"

run: all
	@echo ""
	@echo "--- Running ALU Simulator ---"
	./alu_simulator

clean:
	@echo "[CLEAN] Removing compiled files..."
	rm -f *.o alu_simulator
	@echo "[DONE]  Clean complete"

.PHONY: all run clean
