# ============================================================
# Makefile — BIT 4220 Task 1
# Usage:
#   make          → builds both programs
#   make run      → builds and runs both
#   make clean    → removes compiled files
# ============================================================

NASM      = nasm
LD        = ld
NASMFLAGS = -f elf64

all: hello data_demo

hello: asm/hello.asm
	@echo "[NASM] Assembling hello.asm..."
	$(NASM) $(NASMFLAGS) asm/hello.asm -o hello.o
	@echo "[LD]   Linking hello.o..."
	$(LD) hello.o -o hello
	@echo "[DONE] hello is ready"

data_demo: asm/data_demo.asm
	@echo "[NASM] Assembling data_demo.asm..."
	$(NASM) $(NASMFLAGS) asm/data_demo.asm -o data_demo.o
	@echo "[LD]   Linking data_demo.o..."
	$(LD) data_demo.o -o data_demo
	@echo "[DONE] data_demo is ready"

run: all
	@echo ""
	@echo "--- Running hello ---"
	./hello
	@echo ""
	@echo "--- Running data_demo ---"
	./data_demo

clean:
	@echo "[CLEAN] Removing compiled files..."
	rm -f *.o hello data_demo
	@echo "[DONE]  Clean complete"

.PHONY: all run clean
