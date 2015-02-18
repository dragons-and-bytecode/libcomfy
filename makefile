CFLAGS=-std=c11 -Iinclude
CC=clang
CHECKFLAGS=`pkg-config check --libs`

all_src=$(wildcard src/*.comfy)
all_headers=$(patsubst src/%.comfy,include/%.h,$(all_src))
all_c_src=$(patsubst src/%.comfy,build/c/%.c,$(all_src))
all_obj=$(patsubst src/%.comfy,build/o/%.o,$(all_src))

libcomfy.a: $(all_obj)
	$(AR) rcs $@ $^


build/o/%.o: build/c/%.c | $(all_headers) prepare
	$(CC) $(CFLAGS) -c -o $@ $?

build/c/%.c: src/%.comfy | prepare
	comfy --source $(?D) --target $(@D) $(?F) --c-files

include/%.h: src/%.comfy | prepare
	comfy --source $(?D) --target $(@D) $(?F) --headers

.SECONDARY: $(all_headers)

clean:
	$(RM) -r build
	$(RM) $(all_headers)

#### Unit Testing with Check

CK_VERBOSITY=CK_MINIMAL
all_tests=$(wildcard test/*.ts)

build/check/testsuite.c: $(all_tests) | prepare
	checkmk $^ >$@

build/check/testsuite: build/check/testsuite.c | libcomfy.a
	$(CC) $(CFLAGS) -o $@ $(CHECKFLAGS) -lcomfy -L. $^

check: build/check/testsuite
	build/check/testsuite

####

prepare:
	@mkdir -p build/c
	@mkdir -p build/o
	@mkdir -p build/check

.PHONY: clean prepare check
