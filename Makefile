CRYSTAL ?= crystal
CC      ?= $(shell command -v clang 2>/dev/null || command -v cc 2>/dev/null || echo cc)
AR      ?= ar
CFLAGS  ?= -O2 -fPIC -Wall -Wextra -std=c99

# ── paths ────────────────────────────────────────────────────────────────
NANOARROW_SRC := arrow-nanoarrow/src/nanoarrow
EXT_SRC       := ext/nanoarrow
EXT_WRAP      := ext/nanoarrow_bridge
BUILD_DIR     := ext/build

LIB := $(BUILD_DIR)/libnanoarrow_bridge.a

NA_COMMON := array schema utils array_stream
NA_OBJS   := $(addprefix $(BUILD_DIR)/na_common/,$(addsuffix .o,$(NA_COMMON)))
WRAP_OBJ  := $(BUILD_DIR)/nanoarrow_bridge.o

# For #include "nanoarrow/nanoarrow.h"
INCLUDES := -Iext

.PHONY: all help build_ext test examples distcheck copy_nanoarrow clean

all: build_ext

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  make              Build ext/build/libnanoarrow_bridge.a' \
	  '  make build_ext    Build the bundled nanoarrow bridge static library' \
	  '  make test         Build the C library, then run Crystal tests' \
	  '  make examples     Build the C library, then run examples/build_arrays.cr' \
	  '  make distcheck    Build the C library for distribution checks' \
	  '  make copy_nanoarrow  Copy nanoarrow sources from the submodule into ext/' \
	  '  make clean        Remove ext/build' \
	  '' \
	  'Variables:' \
	  '  CRYSTAL           Crystal compiler command, default: crystal' \
	  '  CC                C compiler, default: clang or cc' \
	  '  AR                Static archive command, default: ar' \
	  '  CFLAGS            C compiler flags'

# ── copy nanoarrow sources from submodule ────────────────────────────────
$(EXT_SRC)/nanoarrow.h: $(NANOARROW_SRC)/nanoarrow.h
	mkdir -p $(EXT_SRC)/common
	cp $(NANOARROW_SRC)/nanoarrow.h            $(EXT_SRC)/nanoarrow.h
	cp $(NANOARROW_SRC)/common/inline_types.h  $(EXT_SRC)/common/inline_types.h
	cp $(NANOARROW_SRC)/common/inline_buffer.h $(EXT_SRC)/common/inline_buffer.h
	cp $(NANOARROW_SRC)/common/inline_array.h  $(EXT_SRC)/common/inline_array.h
	cp $(NANOARROW_SRC)/common/array.c         $(EXT_SRC)/common/array.c
	cp $(NANOARROW_SRC)/common/schema.c        $(EXT_SRC)/common/schema.c
	cp $(NANOARROW_SRC)/common/utils.c         $(EXT_SRC)/common/utils.c
	cp $(NANOARROW_SRC)/common/array_stream.c  $(EXT_SRC)/common/array_stream.c

copy_nanoarrow: $(EXT_SRC)/nanoarrow.h $(EXT_SRC)/nanoarrow_config.h

# ── generate nanoarrow_config.h ──────────────────────────────────────────
$(EXT_SRC)/nanoarrow_config.h: | $(EXT_SRC)/nanoarrow.h
	printf '%s\n' \
	  '#ifndef NANOARROW_CONFIG_H_INCLUDED' \
	  '#define NANOARROW_CONFIG_H_INCLUDED' \
	  '#define NANOARROW_VERSION_MAJOR 0' \
	  '#define NANOARROW_VERSION_MINOR 8' \
	  '#define NANOARROW_VERSION_PATCH 0' \
	  '#define NANOARROW_VERSION "0.8.0"' \
	  '#define NANOARROW_VERSION_INT (NANOARROW_VERSION_MAJOR * 10000 + NANOARROW_VERSION_MINOR * 100 + NANOARROW_VERSION_PATCH)' \
	  '#endif' \
	  > $(EXT_SRC)/nanoarrow_config.h

# ── directories ──────────────────────────────────────────────────────────
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/na_common: | $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/na_common

# ── compile nanoarrow sources ────────────────────────────────────────────
$(BUILD_DIR)/na_common/%.o: $(EXT_SRC)/common/%.c \
    $(EXT_SRC)/nanoarrow.h $(EXT_SRC)/nanoarrow_config.h | $(BUILD_DIR)/na_common
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# ── compile bridge wrapper ───────────────────────────────────────────────
$(WRAP_OBJ): $(EXT_WRAP)/nanoarrow_bridge.c $(EXT_WRAP)/nanoarrow_bridge.h \
    $(EXT_SRC)/nanoarrow.h $(EXT_SRC)/nanoarrow_config.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -I$(EXT_WRAP) -c $< -o $@

# ── static library ───────────────────────────────────────────────────────
$(LIB): $(NA_OBJS) $(WRAP_OBJ)
	$(AR) rcs $@ $^

build_ext: $(LIB)

# ── Crystal tasks ────────────────────────────────────────────────────────
test: build_ext
	$(CRYSTAL) spec

examples: build_ext
	$(CRYSTAL) run examples/build_arrays.cr

distcheck: build_ext

clean:
	rm -rf $(BUILD_DIR)