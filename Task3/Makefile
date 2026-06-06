# ============================================================
# Makefile — BIT 4220 Task 3: Marks Processor
# Usage:
#   make          → builds marks_processor
#   make run      → builds and runs
#   make clean    → removes compiled files
# ============================================================

NASM      = nasm
LD        = ld
NASMFLAGS = -f elf64

all: marks_processor

marks_processor: asm/marks_processor.asm
	@echo "[NASM] Assembling marks_processor.asm..."
	$(NASM) $(NASMFLAGS) asm/marks_processor.asm -o marks_processor.o
	@echo "[LD]   Linking marks_processor.o..."
	$(LD) marks_processor.o -o marks_processor
	@echo "[DONE] marks_processor is ready"

run: all
	@echo ""
	@echo "--- Running Marks Processor ---"
	./marks_processor

clean:
	@echo "[CLEAN] Removing compiled files..."
	rm -f *.o marks_processor
	@echo "[DONE]  Clean complete"

.PHONY: all run clean

