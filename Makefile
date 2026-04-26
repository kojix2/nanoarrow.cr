CRYSTAL ?= crystal
CC      ?= $(shell command -v clang 2>/dev/null || command -v cc 2>/dev/null || echo cc)
AR      ?= ar
CFLAGS  ?= -O2 -fPIC -Wall -Wextra -std=c99

NANOARROW_SRC := arrow-nanoarrow/src/nanoarrow
EXT_SRC       := ext/nanoarrow
EXT_WRAP      := ext/nanoarrow_bridge
BUILD_DIR     := ext/build

LIB := $(BUILD_DIR)/libnanoarrow_bridge.a

NA_COMMON := array schema utils array_stream
NA_OBJS   := $(addprefix $(BUILD_DIR)/na_common/,$(addsuffix .o,$(NA_COMMON)))
WRAP_OBJ  := $(BUILD_DIR)/nanoarrow_bridge.o

INCLUDES := -Iext

.PHONY: all help build_ext test examples distcheck copy_nanoarrow clean

all: build_ext

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  make                 Build ext/build/libnanoarrow_bridge.a' \
	  '  make build_ext       Build the bundled static library' \
	  '  make test            Build the C library, then run Crystal specs' \
	  '  make examples        Build the C library, then run examples/build_arrays.cr' \
	  '  make copy_nanoarrow  Copy nanoarrow sources from the submodule into ext/' \
	  '  make clean           Remove ext/build'

copy_nanoarrow:
	mkdir -p $(EXT_SRC)/common
	cp $(NANOARROW_SRC)/nanoarrow.h            $(EXT_SRC)/nanoarrow.h
	cp $(NANOARROW_SRC)/common/inline_types.h  $(EXT_SRC)/common/inline_types.h
	cp $(NANOARROW_SRC)/common/inline_buffer.h $(EXT_SRC)/common/inline_buffer.h
	cp $(NANOARROW_SRC)/common/inline_array.h  $(EXT_SRC)/common/inline_array.h
	cp $(NANOARROW_SRC)/common/array.c         $(EXT_SRC)/common/array.c
	cp $(NANOARROW_SRC)/common/schema.c        $(EXT_SRC)/common/schema.c
	cp $(NANOARROW_SRC)/common/utils.c         $(EXT_SRC)/common/utils.c
	cp $(NANOARROW_SRC)/common/array_stream.c  $(EXT_SRC)/common/array_stream.c

$(EXT_SRC)/nanoarrow_config.h:
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

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/na_common: | $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/na_common

$(BUILD_DIR)/na_common/%.o: $(EXT_SRC)/common/%.c \
    $(EXT_SRC)/nanoarrow.h $(EXT_SRC)/nanoarrow_config.h | $(BUILD_DIR)/na_common
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(WRAP_OBJ): $(EXT_WRAP)/nanoarrow_bridge.c $(EXT_WRAP)/nanoarrow_bridge.h \
    $(EXT_SRC)/nanoarrow.h $(EXT_SRC)/nanoarrow_config.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -I$(EXT_WRAP) -c $< -o $@

$(LIB): $(NA_OBJS) $(WRAP_OBJ)
	$(AR) rcs $@ $^

build_ext: $(LIB)

test: build_ext
	$(CRYSTAL) spec

examples: build_ext
	$(CRYSTAL) run examples/build_arrays.cr

distcheck: build_ext

clean:
	rm -rf $(BUILD_DIR)