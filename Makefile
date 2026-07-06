.PHONY: all install clean

ASM=8088_add_tests.asm
OUT=add_tests.com

all: $(OUT)

install:
	@echo "Checking for nasm..."
	@if command -v nasm >/dev/null 2>&1; then \
		echo "nasm is already installed"; \
	else \
		if command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y nasm; \
		elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y nasm; \
		elif command -v yum >/dev/null 2>&1; then sudo yum install -y nasm; \
		elif command -v pacman >/dev/null 2>&1; then sudo pacman -Sy --noconfirm nasm; \
		elif command -v brew >/dev/null 2>&1; then brew install nasm; \
		else echo "Could not find a supported package manager. Please install nasm manually." && exit 1; \
		fi; \
	fi

$(OUT): $(ASM)
	nasm -f bin -o $@ $<

clean:
	rm -f $(OUT)
