CFLAGS=-std=c11 -Iinclude
CC=clang

all_src=$(wildcard src/*.comfy)
all_headers=$(patsubst src/%.comfy,include/%.h,$(all_src))
all_c_src=$(patsubst src/%.comfy,build/c/%.c,$(all_src))
all_obj=$(patsubst src/%.comfy,build/o/%.o,$(all_src))

libcomfy.a: $(all_obj)
	$(AR) rcs $@ $^


build/o/%.o: build/c/%.c | $(all_headers) prepare
	$(CC) $(CFLAGS) -Iinclude -c -o $@ $?

build/c/%.c: src/%.comfy | prepare
	comfy --source $(?D) --target $(@D) $(?F) --c-files

include/%.h: src/%.comfy | prepare
	comfy --source $(?D) --target $(@D) $(?F) --headers
	
.SECONDARY: $(all_headers)

clean:
	$(RM) -r build
	$(RM) $(all_headers)

prepare:
	mkdir -p build/c
	mkdir -p build/o
